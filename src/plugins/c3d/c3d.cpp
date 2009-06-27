/*! \file
 *  \author KUDOH Shunsuke
 *  $Id: c3d.cpp 923 2009-06-03 12:53:38Z shun $
 *
 *  This code works well only on Intel platforms!
 *    sizeof(int)==4, sizeof(short)==2, little endian, ....
 */
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cmath>
#include <boost/format.hpp>
#include "c3d.h"
using namespace std;

//#define _C3D_DEBUG_

#ifndef IOBINARY_MODE
#if defined(_WIN32) || defined(__MSDOS__)
#define OSBINARY_MODE (ios::out | ios::binary)
#define ISBINARY_MODE (ios::in | ios::binary)
#else
#define OSBINARY_MODE (ios::out)
#define ISBINARY_MODE (ios::in)
#endif //defined(_WIN32) || defined(__MSDOS__)
#endif //IOBINARY_MODE


//////////////////////////////////////////////////////////////////////
//
// C3D
//
//////////////////////////////////////////////////////////////////////


C3D::C3D() : err(NoError), mCntByte(0), mFormat(Floating)
{
    mError.push_back(KdhErrorElement(CannotOpenFile, "cannot open file: %s"));
    mError.push_back(KdhErrorElement(NotC3DFile, "the file does not seem C3D file"));
    mError.push_back(KdhErrorElement(UnknownProcessorType, "Unknown processor type: %d"));
    mError.push_back(KdhErrorElement(InvalidData1, "ID %d  Name %s: invalid data"));
    mError.push_back(KdhErrorElement(InvalidData2, "ID %d  Name %s: no goup which has ID %d"));
    mError.push_back(KdhErrorElement(NoRequiredParameter, "no required parameter: %s"));
    mError.push_back(KdhErrorElement(InvalidDataType, "invalid data type: %s: %s"));
}


bool
C3D::load(const string& fname)
{
    ifstream is(fname.c_str(), ISBINARY_MODE);
    if (!is) {
        mError.setIndex(CannotOpenFile);
        mError.setMessage((boost::format(mError[CannotOpenFile].message) % fname).str());
	return false;
    }
    return load(is);
}


bool
C3D::load(istream& is)
{
    if (!readHeader(is) || !readParameter(is) || !readData(is))
	return false;
    return true;
}


bool
C3D::readHeader(istream& is)
{
    parameter.processorType = Intel; // default value

    header.ptrToParameterSection = readChar(is);

    if (readChar(is) != 0x50) {
        mError.setIndex(NotC3DFile);
        mError.setMessage(mError[NotC3DFile].message);
	return false;
    }

    header.nPoint = readInt(is);
    header.nAnalogMeasurement = readInt(is);
    header.firstFrame = readInt(is);
    header.lastFrame = readInt(is);
    header.maxInterpolationGap = readInt(is);
    header.scaleFactor = readFloat(is);
    header.ptrToDataSection = readInt(is);
    header.nAnalogSample = readInt(is);
    header.frameRate = readFloat(is);

#ifdef _C3D_DEBUG_
    cerr << "C3D::readHeader()"
         << "\n\tptrToParameterSection = " << header.ptrToParameterSection
         << "\n\tnPoint = " << header.nPoint
         << "\n\tnAnalogMeasurement = " << header.nAnalogMeasurement
         << "\n\tfirstFrame = " << header.firstFrame
         << "\n\tlastFrame = " << header.lastFrame
         << "\n\tmaxInterpolationGap = " << header.maxInterpolationGap
         << "\n\tscaleFactor = " << header.scaleFactor
         << "\n\tptrToDataSection = " << header.ptrToDataSection
         << "\n\tnAnalogSample = " << header.nAnalogSample
         << "\n\tframeRate = " << header.frameRate << endl;
#endif//_C3D_DEBUG_

    if (header.scaleFactor > 0)
        mFormat = Integer;

    return true;
}


/*!
 *  This function should be called after calling readHeader().
 */
bool
C3D::readParameter(std::istream& is)
{
    //// move to the top of Parameter Section
    int top_of_parameter_section = 512 * (header.ptrToParameterSection - 1);
    is.ignore(top_of_parameter_section - mCntByte);
    mCntByte = top_of_parameter_section;

    //// ignore the first two byte
    is.get();
    is.get();
    mCntByte += 2;

    //// read parameter header
    parameter.nBlock = readChar(is);
    parameter.processorType = readChar(is) - 83;

    // if processor type is not Intel...
    switch (parameter.processorType) {
    case Intel:
        break; // nothing to do

    case DEC:
        header.scaleFactor = convertFloatDecToIntel(header.scaleFactor);
        if (header.scaleFactor > 0)
            mFormat = Integer;
        header.frameRate = convertFloatDecToIntel(header.frameRate);
#ifdef _C3D_DEBUG_
        cerr << "  *** processor type is DEC! ***\n"
             << "\tscaleFactor = " << header.scaleFactor << "\n\tframeRate = " << header.frameRate << endl;
#endif//_C3D_DEBUG_
        break;

    case MIPS:
        header.nPoint = convertIntMipsToIntel(header.nPoint);
        header.nAnalogMeasurement = convertIntMipsToIntel(header.nAnalogMeasurement);
        header.firstFrame = convertIntMipsToIntel(header.firstFrame);
        header.lastFrame = convertIntMipsToIntel(header.lastFrame);
        header.maxInterpolationGap = convertIntMipsToIntel(header.maxInterpolationGap);
        header.scaleFactor = convertFloatMIPSToIntel(header.scaleFactor);
        if (header.scaleFactor > 0)
            mFormat = Integer;
        header.ptrToDataSection = convertIntMipsToIntel(header.ptrToDataSection);
        header.nAnalogSample = convertIntMipsToIntel(header.nAnalogSample);
        header.frameRate = convertFloatMIPSToIntel(header.frameRate);
#ifdef _C3D_DEBUG_
        cerr << "  *** processor type is MIPS! ***"
             << "\n\tptrToParameterSection = " << header.ptrToParameterSection
             << "\n\tnPoint = " << header.nPoint
             << "\n\tnAnalogMeasurement = " << header.nAnalogMeasurement
             << "\n\tfirstFrame = " << header.firstFrame
             << "\n\tlastFrame = " << header.lastFrame
             << "\n\tmaxInterpolationGap = " << header.maxInterpolationGap
             << "\n\tscaleFactor = " << header.scaleFactor
             << "\n\tptrToDataSection = " << header.ptrToDataSection
             << "\n\tnAnalogSample = " << header.nAnalogSample
             << "\n\tframeRate = " << header.frameRate
             << endl;
#endif//_C3D_DEBUG_
        break;

    default:
        mError.setIndex(UnknownProcessorType);
        mError.setMessage((boost::format(mError[UnknownProcessorType].message) % static_cast<int>(parameter.processorType)).str());
        return false;
    }

#ifdef _C3D_DEBUG_
    cerr << "C3D::readParameter()"
         << "\n\tnBlock = " << (int)parameter.nBlock
         << "\n\tprocessorType = " << (int)parameter.processorType << flush;
#endif//_C3D_DEBUG_

    for (;;) {
        char nameLength = readChar(is);
        if (nameLength < 0)
            nameLength = -nameLength;
        char id = readChar(is);
        string name;
        name.resize(nameLength);
        for (int i = 0; i < nameLength; ++i)
            name[i] = readChar(is);
        short nextParameter = readInt(is);
        int data_size; // residual data size (byte)

#ifdef _C3D_DEBUG_
        cerr << "\n\tID: " << (int)id
             << "\n\t\tname = (" << (int)nameLength << "):" << name
             << "\n\t\tptrToNextParameter = " << nextParameter << flush;
#endif//_C3D_DEBUG_

        if (id == 0)
            return true;
        else if (id < 0) {
            C3DGroup *gr = readParameterGroupFormat(is, &data_size);
            if (gr == NULL) {
                mError.setIndex(InvalidData1);
                mError.setMessage((boost::format(mError[InvalidData1].message) % (int)id % name).str());
                return false;
            }
            gr->id = id;
            gr->name = name;
            parameter.group.push_back(gr);
        } else {
            C3DParameter *pr = readParameterParameterFormat(is, &data_size);
            if (pr == NULL) {
                mError.setIndex(InvalidData1);
                mError.setMessage((boost::format(mError[InvalidData1].message) % (int)id % name).str());
                return false;
            }
            pr->id = id;
            pr->name = name;

            int gidx = 0;
            for (; gidx < (int)parameter.group.size(); ++gidx)
                if (parameter.group[gidx]->id == -id)
                    break;
            if (gidx >= (int)parameter.group.size()) {
                mError.setIndex(InvalidData2);
                mError.setMessage((boost::format(mError[InvalidData2].message) % (int)id % name % -(int)id).str());
                return false;
            }
            parameter.group[gidx]->parameter.push_back(pr);
        }
        if (nextParameter == 0)
            break;
        else if (nextParameter - data_size > 0) {
            is.ignore(nextParameter - data_size);
            mCntByte += nextParameter - data_size;
        }
    }
    return true;
}


C3DGroup*
C3D::readParameterGroupFormat(istream& is, int *data_size)
{
    C3DGroup *gr = new C3DGroup;
    int descriptionLength = readChar(is);
    gr->description.resize(descriptionLength);
    for (int i = 0; i < descriptionLength; ++i)
        gr->description[i] = readChar(is);
    *data_size = descriptionLength + 3;   // data_size includes nextParameter (2byte)

#ifdef  _C3D_DEBUG_
    cerr << "\n\t\tdescription = " << gr->description << flush;
#endif//_C3D_DEBUG_

    return gr;
}


C3DParameter*
C3D::readParameterParameterFormat(std::istream& is, int *data_size)
{
    int type = readChar(is);
    int nDim = readChar(is);
    *data_size = 4;  // data_size includes nextParameter (2byte)

    C3DParameter *pr;
    C3DParameterChar *pc;
    C3DParameterInt *pi;
    C3DParameterFloat *pf;
    switch (type) {
    case -1:
        pc = new C3DParameterChar;
        if (nDim == 0) {
            pc->data.push_back(string(1, readChar(is)));
            *data_size += 1;
        } else {
            pc->dim.resize(nDim);
            int string_size = readChar(is);
            int array_size = 1;
            pc->dim[0] = string_size;
            for (int i = 1; i < nDim; ++i) {
                pc->dim[i] = readChar(is);
                array_size *= pc->dim[i];
            }
            pc->data.resize(array_size);
            for (int i = 0; i < array_size; ++i) {
                pc->data[i].resize(string_size);
                for (int j = 0; j < string_size; ++j)
                    pc->data[i][j] = readChar(is);
            }
            *data_size += nDim + array_size * string_size;
        }
        pr = pc;

#ifdef _C3D_DEBUG_
        cerr << "\n\t\ttype = " << (int)type
             << "\n\t\tdimension = (" << (int)nDim << "):";
        for (int i = 0; i < nDim; ++i)
            cerr << ' ' << (int)pc->dim[i];
        for (size_t i = 0; i < pc->data.size(); ++i)
            cerr << "\n\t\t   " << pc->data[i];
        cerr << flush;
#endif//_C3D_DEBUG_

        break;
    case 1:
        pi = new C3DParameterInt;
        if (nDim == 0) {
            pi->data.push_back(readChar(is));
            *data_size += 1;
        } else {
            pi->dim.resize(nDim);
            int array_size = 1;
            for (int i = 0; i < nDim; ++i) {
                pi->dim[i] = readChar(is);
                array_size *= pi->dim[i];
            }
            pi->data.resize(array_size);
            for (int i = 0; i < array_size; ++i)
                pi->data[i] = readChar(is);
            *data_size += nDim + array_size;
        }
        pr = pi;

#ifdef _C3D_DEBUG_
        cerr << "\n\t\ttype = " << (int)type
             << "\n\t\tdimension = (" << (int)nDim << "):";
        for (int i = 0; i < nDim; ++i)
            cerr << ' ' << (int)pi->dim[i];
        cerr << "\n\t\t  ";
        for (size_t i = 0; i < pi->data.size(); ++i)
            cerr << ' ' << pi->data[i];
        cerr << flush;
#endif//_C3D_DEBUG_

        break;
    case 2:
        pi = new C3DParameterInt;
        if (nDim == 0) {
            pi->data.push_back(readInt(is));
            *data_size += 2;
        } else {
            pi->dim.resize(nDim);
            int array_size = 1;
            for (int i = 0; i < nDim; ++i) {
                pi->dim[i] = readChar(is);
                array_size *= pi->dim[i];
            }
            pi->data.resize(array_size);
            for (int i = 0; i < array_size; ++i)
                pi->data[i] = readInt(is);
            *data_size += nDim + array_size * 2;
        }
        pr = pi;

#ifdef _C3D_DEBUG_
        cerr << "\n\t\ttype = " << (int)type
             << "\n\t\tdimension = (" << (int)nDim << "):";
        for (int i = 0; i < nDim; ++i)
            cerr << ' ' << (int)pi->dim[i];
        cerr << "\n\t\t  ";
        for (size_t i = 0; i < pi->data.size(); ++i)
            cerr << ' ' << pi->data[i];
        cerr << flush;
#endif//_C3D_DEBUG_

        break;
    case 4:
        pf = new C3DParameterFloat;
        if (nDim == 0) {
            pf->data.push_back(readFloat(is));
            *data_size += 4;
        } else {
            pf->dim.resize(nDim);
            int array_size = 1;
            for (int i = 0; i < nDim; ++i) {
                pf->dim[i] = readChar(is);
                array_size *= pf->dim[i];
            }
            pf->data.resize(array_size);
            for (int i = 0; i < array_size; ++i)
                pf->data[i] = readFloat(is);
            *data_size += nDim + array_size * 4;
        }
        pr = pf;

#ifdef _C3D_DEBUG_
        cerr << "\n\t\ttype = " << (int)type
             << "\n\t\tdimension = (" << (int)nDim << "):";
        for (int i = 0; i < nDim; ++i)
            cerr << ' ' << (int)pf->dim[i];
        cerr << "\n\t\t  ";
        for (size_t i = 0; i < pf->data.size(); ++i)
            cerr << ' ' << pf->data[i];
        cerr << flush;
#endif//_C3D_DEBUG_

        break;
    default:
        return NULL;
    }
    pr->type = type;
    pr->nDim = nDim;
    int descriptionLength = readChar(is);
    pr->description.resize(descriptionLength);
    for (int i = 0; i < descriptionLength; ++i)
        pr->description[i] = readChar(is);
    *data_size += descriptionLength + 1;

#ifdef _C3D_DEBUG_
    cerr << "\n\t\tdescription = " << pr->description << flush;
#endif//_C3D_DEBUG_

    return pr;
}


/*!
 *  This function should be called after calling readParameter().
 */
bool
C3D::readData(std::istream& is)
{
    enum ANALOG_FORMAT {SIGNED, UNSIGNED};

    //// move to the top of Data Section
    int top_of_data_section = 512 * (header.ptrToDataSection - 1);
    is.ignore(top_of_data_section - mCntByte);
    mCntByte = top_of_data_section;

    //// get parameters for analog data
    vector<int> offset;
    vector<float> scale;
    int n_analog_channel = 0;
    float gen_scale = 0.0;
    int format = SIGNED;  // ANALOG:FORMAT (default is SIGNED)
    int bits = 12;        // ANALOG:BITS (defalult is 12)
    if (header.nAnalogMeasurement > 0) {
        n_analog_channel = header.nAnalogMeasurement / header.nAnalogSample;

        // ANALOG:OFFSET and Integer Analog Data are unsigned
        // if (ANALOG:FORMAT == "UNSIGNED") or (ANALOG:FORMAT is not defined && ANALOG:BITS == 16)
        C3DParameter *pr = getParameter("ANALOG:BITS");
        if (pr != NULL)
            bits = ((C3DParameterInt*)pr)->data[0];
        pr = getParameter("ANALOG:FORMAT");
        if (pr != NULL) {
            if (((C3DParameterChar*)pr)->data[0] == "SIGNED")
                format = SIGNED;
            else if (((C3DParameterChar*)pr)->data[0] == "UNSIGNED")
                format = UNSIGNED;
            else {
                mError.setIndex(InvalidDataType);
                mError.setMessage((boost::format(mError[InvalidDataType].message) % "ANALOG:FORMAT" % ((C3DParameterChar*)pr)->data[0]).str());
                return -1;
            }
        } else
            if (bits == 16)
                format = UNSIGNED;
        
        pr = getParameter("ANALOG:OFFSET");
        if (pr == NULL) {
            mError.setIndex(NoRequiredParameter);
            mError.setMessage((boost::format(mError[NoRequiredParameter].message) % "ANALOG:OFFSET").str());
            return false;
        }
        offset.resize(((C3DParameterInt*)pr)->data.size());
        for (size_t i = 0; i < ((C3DParameterInt*)pr)->data.size(); ++i)
            if (format == SIGNED)
                offset[i] = ((C3DParameterInt*)pr)->data[i];
            else
                offset[i] = (unsigned short)((C3DParameterInt*)pr)->data[i];
        
        pr = getParameter("ANALOG:SCALE");
        if (pr == NULL) {
            mError.setIndex(NoRequiredParameter);
            mError.setMessage((boost::format(mError[NoRequiredParameter].message) % "ANALOG:SCALE").str());
            return false;
        }
        scale = ((C3DParameterFloat*)pr)->data;

        pr = getParameter("ANALOG:GEN_SCALE");
        if (pr == NULL) {
            mError.setIndex(NoRequiredParameter);
            mError.setMessage((boost::format(mError[NoRequiredParameter].message) % "ANALOG:GEN_SCALE").str());
            return false;
        }
        gen_scale = ((C3DParameterFloat*)pr)->data[0];
    }

    //// allocate memory
    C3DFrame frm;
    frm.point.resize(header.nPoint);
    if (n_analog_channel > 0) {
        frm.analog.resize(header.nAnalogSample);
        for (size_t i = 0; i < frm.analog.size(); ++i)
            frm.analog[i].resize(n_analog_channel);
    }

    //// read data
    for (int idx = header.firstFrame; idx <= header.lastFrame; ++idx) {

        //// read point data
        for (size_t i = 0; i < frm.point.size(); ++i) {
            if (mFormat == Integer) {
                frm.point[i].x = readInt(is) * header.scaleFactor;
                frm.point[i].y = readInt(is) * header.scaleFactor;
                frm.point[i].z = readInt(is) * header.scaleFactor;
                unsigned int n = readInt(is);
                frm.point[i].residual = (n & 0x000000FF) / header.scaleFactor;
                frm.point[i].camera = (unsigned char)((n & 0x0000FF00) >> 8);
            } else {
                frm.point[i].x = readFloat(is);
                frm.point[i].y = readFloat(is);
                frm.point[i].z = readFloat(is);
                unsigned int n = (unsigned int)readFloat(is);
                frm.point[i].residual = (n & 0x000000FF) / -header.scaleFactor;
                frm.point[i].camera = (unsigned char)((n & 0x0000FF00) >> 8);
            }
        }

        //// read analog data
        if (n_analog_channel > 0) {
            for (size_t i = 0; i < frm.analog.size(); ++i)
                for (size_t j = 0; j < frm.analog[i].size(); ++j)
                    if (mFormat == Integer) {
                        int val = (format == SIGNED) ? readInt(is) : (unsigned short)readInt(is);
                        frm.analog[i][j] = (val - offset[j]) * scale[j] * gen_scale;
                    } else
                        frm.analog[i][j] = (readFloat(is) - offset[j]) * scale[j] * gen_scale;
        }
        frame.push_back(frm);
    }
    return true;
}


C3DParameter*
C3D::getParameter(const string& str)
{
    size_t sep = str.find(':');
    if (sep == 0 || sep >= str.size())
        return NULL;
    string grp(str.substr(0, sep));
    string prm(str.substr(sep + 1));

    for (size_t i = 0; i < parameter.size(); ++i)
        if (parameter[i]->name == grp)
            for (size_t j = 0; j < parameter[i]->size(); ++j)
                if ((*parameter[i])[j]->name == prm)
                    return (*parameter[i])[j];
    return NULL;
}



/*!
 *   \param param <group name>:<parameter name>
 *   \param label string that you want to find
 *
 *      Example:  int index = c3d.findLabelIndex("POINT:LABES", "RFWT");
 */
int
C3D::findLabelIndex(const string& param, const string& label)
{
    C3DParameterChar *pc = (C3DParameterChar*)getParameter(param);
    if (pc == NULL) {
        mError.setIndex(NoRequiredParameter);
        mError.setMessage((boost::format(mError[NoRequiredParameter].message) % param).str());
        return -1;
    } else if (pc->type != pc->CHAR) {
        mError.setIndex(InvalidDataType);
        mError.setMessage((boost::format(mError[InvalidDataType].message) % param % "should be a CHAR-type").str());
        return -1;
    }

    for (size_t i = 0; i < pc->data.size(); ++i)
        if (pc->data[i] == label || removeSpace(pc->data[i]) == label)
            return i;
    return -1;
}


string
C3D::removeSpace(const string& str)
{
    int beg = 0, end = str.size() - 1;
    while (beg < end && (str[beg] == ' ' || str[beg] == '\t'))
        ++beg;
    if (beg >= end)
        return string();
    while (beg <= end && (str[end] == ' ' || str[end] == '\t'))
        --end;
    return str.substr(beg, end + 1);
}


char
C3D::readChar(std::istream& is)
{
    ++mCntByte;
    return is.get();
}


short
C3D::readInt(std::istream& is)
{
    char w[2];
    mCntByte += 2;
    is.read(w, 2);
    switch (parameter.processorType) {
    case Intel:
    case DEC:
        return ((unsigned char)w[0] + (unsigned char)w[1] * 256);
    case MIPS:
        return ((unsigned char)w[1] + (unsigned char)w[0] * 256);
    }
    return 0; // never reach here
}


float
C3D::readFloat(std::istream& is)
{
    char w[4];
    float f;
    mCntByte += 4;
    is.read(w, 4);

    switch (parameter.processorType) {
    case Intel:
        ((char*)(&f))[0] = w[0];
        ((char*)(&f))[1] = w[1];
        ((char*)(&f))[2] = w[2];
        ((char*)(&f))[3] = w[3];
        return f;
    case DEC:
        ((char*)(&f))[0] = w[2];
        ((char*)(&f))[1] = w[3];
        ((char*)(&f))[2] = w[0];
        ((char*)(&f))[3] = w[1];
        f /= 4.0; // I don't know why, but everything goes well after this operation...
        return f;
    case MIPS:
        ((char*)(&f))[0] = w[3];
        ((char*)(&f))[1] = w[2];
        ((char*)(&f))[2] = w[1];
        ((char*)(&f))[3] = w[0];
        return f;
    }
    return 0; // never reach here
}


/*! Returns an Intel formatted integer number.
 *    \Param [in] f MIPS formatted integer number
 */
int
C3D::convertIntMipsToIntel(int i)
{
    char tmp;
    tmp = ((char*)(&i))[0];
    ((char*)(&i))[0] = ((char*)(&i))[1];
    ((char*)(&i))[1] = tmp;
    return i;
}


/*! Returns Intel formatted float number.
 *    \Param [in] f Dec formatted float number
 */
float
C3D::convertFloatDecToIntel(float f)
{
    char w[4];
    for (size_t i = 0; i < 4; ++i)
        w[i] = ((char*)(&f))[i];
    ((char*)(&f))[0] = w[2];
    ((char*)(&f))[1] = w[3];
    ((char*)(&f))[2] = w[0];
    ((char*)(&f))[3] = w[1];
    f /= 4.0; // I don't know why, but everything goes well after this operation...
    return f;
}


/*! Returns an Intel formatted float number.
 *    \Param [in] f MIPS formatted float number
 */
float
C3D::convertFloatMIPSToIntel(float f)
{
    char w[4];
    for (size_t i = 0; i < 4; ++i)
        w[i] = ((char*)(&f))[i];
    ((char*)(&f))[0] = w[3];
    ((char*)(&f))[1] = w[2];
    ((char*)(&f))[2] = w[1];
    ((char*)(&f))[3] = w[0];
    return f;
}


bool
C3D::write(const std::string& fname)
{
    ofstream os(fname.c_str(), OSBINARY_MODE);
    if (!os) {
        mError.setIndex(CannotOpenFile);
        mError.setMessage((boost::format(mError[CannotOpenFile].message) % fname).str());
	return false;
    }
    return write(os);
}


bool
C3D::write(std::ostream& os)
{
    char null_buf[512];
    for (size_t i = 0; i < sizeof(null_buf); ++i)
        null_buf[i] = 0;

    //// header
    os.put(0x02);
    os.put(0x50);
    os.write((char*)&header.nPoint, 2);
    os.write((char*)&header.nAnalogMeasurement, 2);
    os.write((char*)&header.firstFrame, 2);
    os.write((char*)&header.lastFrame, 2);
    os.write((char*)&header.maxInterpolationGap, 2);
    os.write((char*)&header.scaleFactor, 4);
    os.write((char*)&header.ptrToDataSection, 2);
    os.write((char*)&header.nAnalogSample, 2);
    os.write((char*)&header.frameRate, 4);
    os.write(null_buf, 488);                                 // fill first block

    //// parameter
    os.put(0x00);
    os.put(0x00);
    os.put(parameter.nBlock);
    os.put(parameter.processorType + 83);

    for (size_t i = 0; i < parameter.group.size(); ++i) {
        //// -- group
        C3DGroup* gr = parameter.group[i];
        os.put((char)gr->name.size());
        os.put(gr->id);
        os.write(gr->name.c_str(), gr->name.size());
        os.put(0x03), os.put(0x00), os.put(0x00);

        //// -- parameter
        for (size_t j = 0; j < gr->parameter.size(); ++j) {
            C3DParameter* pr = gr->parameter[j];
            os.put((char)pr->name.size());
            os.put(pr->id);
            os.write(pr->name.c_str(), pr->name.size());
            int next;
            if (pr->nDim == 0)
                next = 2 + 1 + 1 + abs(pr->type) + 1;
            else {
                size_t tmp = abs(pr->type);
                for (int k = 0; k < pr->nDim; ++k)
                    tmp *= pr->dim[k];
                next = 2 + 1 + 1 + pr->nDim + tmp + 1;
            }
            os.write((char*)&next, 2);
            os.put(pr->type);
            os.put(pr->nDim);
            for (int k = 0; k < pr->nDim; ++k)
                os.put(pr->dim[k]);
            switch (pr->type) {
            case -1: // CHAR
                for (size_t k = 0; k < ((C3DParameterChar*)pr)->data.size(); ++k)
                    os.write(((C3DParameterChar*)pr)->data[k].c_str(), ((C3DParameterChar*)pr)->data[k].size());
                break;
            case 1:  // INTEGER (1bit)
                for (size_t k = 0; k < ((C3DParameterInt*)pr)->data.size(); ++k)
                    os.put((char)((C3DParameterInt*)pr)->data[k]);
                break;
            case 2: // INTEGER (2bits)
                for (size_t k = 0; k < ((C3DParameterInt*)pr)->data.size(); ++k)
                    os.write((char*)&((C3DParameterInt*)pr)->data[k], 2);
                break;
            case 4: // FLOAT
                for (size_t l = 0; l < ((C3DParameterFloat*)pr)->data.size(); ++l)
                    os.write((char*)&((C3DParameterFloat*)pr)->data[l], 4);
                break;
            default:
                mError.setIndex(InvalidDataType);
                mError.setMessage((boost::format(mError[InvalidDataType].message + " (%d)") % pr->name % "invalid parameter" %(int)pr->type).str());
                return false;
            }
            os.put(0x00);
        }
    }
    os.write(null_buf, 5);                                                   // NULL group

    //// count parameter section size
    size_t parameter_size = 4;                                          // header
    for (size_t i = 0; i < parameter.group.size(); ++i) {
        C3DGroup* g = parameter.group[i];
        parameter_size += (2 + g->name.size() + 2 + 1);                // group format
        for (size_t j = 0; j < g->parameter.size(); ++j) {
            C3DParameter* p = g->parameter[j];
            parameter_size += (2 + p->name.size() + 2 + 1 + 1);        // parameter format
            if (p->nDim == 0)
                parameter_size += abs(p->type);
            else {
                parameter_size += p->nDim;
                size_t tmp = abs(p->type);
                for (int k = 0; k < p->nDim; ++k)
                    tmp *= p->dim[k];
                parameter_size += tmp;
            }
            parameter_size += 1;
        }
    }
    parameter_size += 5;                                                // NULL group
    if (parameter_size % 512 != 0)
        os.write(null_buf, (512 - parameter_size % 512));

    //// data
    parameter_size = 0;
    for (size_t i = 0; i < frame.size(); ++i)
        for (size_t j = 0; j < frame[i].point.size(); ++j) {
            os.write((char*)&frame[i].point[j].x, 4);
            os.write((char*)&frame[i].point[j].y, 4);
            os.write((char*)&frame[i].point[j].z, 4);
            os.write(null_buf, 4);
            parameter_size += 16;
        }
    if (parameter_size % 512 != 0)
        os.write(null_buf, (512 - parameter_size % 512));

    return true;
}

//EOF
