/*! \file
 *  \author KUDOH Shunsuke
 *  $Id: c3d2vpm.cpp 909 2009-01-29 11:47:15Z shun $
 */

#include <iostream>
#include <fstream>
#include <string>
#include <boost/format.hpp>
#include "c3d.h"
using namespace std;

#ifndef OSBINARY_MODE
#if defined(_WIN32) || defined(__MSDOS__)
#define OSBINARY_MODE (ios::out | ios::binary)
#define ISBINARY_MODE (ios::in | ios::binary)
#else
#define OSBINARY_MODE (ios::out)
#define ISBINARY_MODE (ios::in)
#endif //defined(_WIN32) || defined(__MSDOS__)
#endif //OSBINARY_MODE


static void print_header_section(C3D&);
static void print_parameter_section(C3D&);
static void print_vpm(C3D&, ostream&, const char*);
static void print_force(C3D&, ostream&, const char*);
static void print_analog(C3D&, ostream&, const char*);

template<class T> void print_parameter(T *pr);
static void print_parameter(C3DParameterChar *pr);
static void print_parameter_unsigned(C3DParameterInt *pr);
static string remove_space(const string& str);

inline void usage() {
    cerr << "c3d2vpm [-p|-a|-f|-o file] file\n"
         << "  -p parameters, -a analog, -f force\n"
         << "  no option: output vpm file\n"
         << "  '-f' option works only for the mocap system in Aizu Univ." << endl;
    exit(-1);
}


int
main(int argc, char **argv)
{
    string out_file_name;
    bool p_flag = false;
    bool a_flag = false;
    bool f_flag = false;

    while (--argc > 0) {
        if ((*++argv)[0] != '-')
            break;
        switch ((*argv)[1]) {
        case 'p':
            p_flag = true;
            break;
        case 'a':
            a_flag = true;
            break;
        case 'f':
            f_flag = true;
            break;
        case 'o':
            if (--argc <= 0)
                usage();
            out_file_name = *++argv;
            break;
        default:
            usage();
        }
    }
    if (argc <= 0)
        usage();

    C3D c3d;
    if (!c3d.load(*argv)) {
        cerr << "error: " << c3d.errorMessage() << endl;
        return -1;
    }


    if (p_flag) {
        print_header_section(c3d);
        print_parameter_section(c3d);
    } else {
        if (out_file_name.empty()) {
            if (f_flag)
                print_force(c3d, cout, "\n");
            else if (a_flag)
                print_analog(c3d, cout, "\n");
            else
                print_vpm(c3d, cout, "\n");
        } else {
            ofstream os(out_file_name.c_str(), OSBINARY_MODE);
            if (!os) {
                cerr << "error: cannot open file: " << out_file_name << endl;
                return -1;
            }
            if (f_flag)
                print_force(c3d, os, "\x0d\x0a");
            else if (a_flag)
                print_analog(c3d, os, "\x0d\x0a");
            else
                print_vpm(c3d, os, "\x0d\x0a");
        }
    }
    return 0;
}


static void
print_header_section(C3D& c3d)
{
    cout << "--------------------\n       Header\n--------------------" << endl;
    cout << "\npointer to Parameter section = " << c3d.header.ptrToParameterSection
         << "\nnumber of point = " << c3d.header.nPoint
         << "\nnumber of analog measurement = " << c3d.header.nAnalogMeasurement
         << "\nfirst frame = " << c3d.header.firstFrame
         << "\nlast frame = " << c3d.header.lastFrame
         << "\nmax interpolation gap = " << c3d.header.maxInterpolationGap
         << "\nscale factor = " << c3d.header.scaleFactor
         << "\nnAnalogSample = " << c3d.header.nAnalogSample
         << "\nframe rate = " << c3d.header.frameRate
         << endl;
}


static void
print_parameter_section(C3D& c3d)
{
    cout << "\n\n--------------------\n     Parameter\n--------------------" << endl;
    cout << "\nnumber of blocks in Parameter Section = " << (int)c3d.parameter.nBlock
         << "\nprocessor type = ";
    switch (c3d.parameter.processorType) {
    case C3D::Intel:
        cout << "Intel";
        break;
    case C3D::DEC:
        cout << "DEC";
        break;
    case C3D::MIPS:
        cout << "MIPS";
        break;
    default:
        cout << "Unknown processor type...(" << c3d.parameter.processorType << ")";
    }

    for (int i = 0; i < (int)c3d.parameter.group.size(); ++i) {

        cout << "\nGroup " << (int)-c3d.parameter.group[i]->id
             << ": " << c3d.parameter.group[i]->name;
        if (!c3d.parameter.group[i]->description.empty())
            cout << "\n  description = " << c3d.parameter.group[i]->description;

        for (int j = 0; j < (int)c3d.parameter.group[i]->parameter.size(); ++j) {
            C3DParameter *pr = c3d.parameter.group[i]->parameter[j];
            cout << "\n " << pr->name << " (type: " << (int)pr->type;
            for (int k = 0; k < (int)pr->dim.size(); ++k)
                cout << (k == 0 ? ", dim: " : " ") << (int)pr->dim[k];
            cout << ")";

            if (c3d.parameter.group[i]->name == "ANALOG" && pr->name == "OFFSET") {
                //// ANALOG:OFFSET
                ////   if ANALOG:FORMAT is UNSIGNED (or ANALOG:FORMAT is not defined && ANALOG:BITS == 16),
                ////   values in ANALOG:OFFSET is unsigned.  Otherwise, values are signed.
                int bits = 12;
                C3DParameter *tmp = c3d.getParameter("ANALOG:BITS");
                if (tmp != NULL)
                    bits = ((C3DParameterInt*)tmp)->data[0];
                tmp = c3d.getParameter("ANALOG:FORMAT");
                if (tmp == NULL)
                    if (bits == 16)
                        print_parameter_unsigned((C3DParameterInt*)pr);
                    else
                        print_parameter((C3DParameterInt*)pr);
                else
                    if (((C3DParameterChar*)tmp)->data[0] == "SIGNED")
                        print_parameter((C3DParameterInt*)pr);
                    else if (((C3DParameterChar*)tmp)->data[0] == "UNSIGNED")
                        print_parameter_unsigned((C3DParameterInt*)pr);
                continue;
            }                

            switch (pr->type) {
            case -1:
                print_parameter((C3DParameterChar*)pr);
                break;
            case 1:
            case 2:
                print_parameter((C3DParameterInt*)pr);
                break;
            case 4:
                print_parameter((C3DParameterFloat*)pr);
                break;
            default:
                cerr << "something wrong..." << endl;
                exit(-1);
            }
        }
    }
    cout << endl;
}


/*!
 *  In this function, the coordinate system is converted.
    \verbatim
        C3D ---> VPM
         x       -x
         y        z
         z        y
    \endverbatim
 */
static void
print_vpm(C3D& c3d, ostream& os, const char *eol)
{
    C3DParameterChar *pc;
    pc = (C3DParameterChar*)c3d.getParameter("POINT:UNITS");
    if (pc == NULL) {
        cerr << "error: cannot find required parameter: POINT:UNITS" << endl;
        exit(-1);
    }
    if (remove_space(pc->data[0]) != "mm")
        cerr << "warning: unit of point data is not \"mm\".";

    pc = (C3DParameterChar*)c3d.getParameter("POINT:LABELS");
    if (pc == NULL) {
        cerr << "error: cannot find required parameter: POINT:LABELS" << endl;
        exit(-1);
    }

    const float M2I = 0.03937;
    for (int i = 0; i < c3d.header.nPoint; ++i) {
        string label_name;
        if (i < static_cast<int>(pc->data.size())) {
            if (pc->data[i][0] == '*') // skip 'unknown label'
                continue;
            label_name = remove_space(pc->data[i]);
        } else
            label_name = str(boost::format("%04d") % i);

        int nFrame = c3d.header.lastFrame - c3d.header.firstFrame + 1;
        
        os << "Segment:\t" << label_name << eol;
        os << "Frames:\t" << nFrame << eol;
        os << "Frame Time:\t" << (1.0 / (float)c3d.header.frameRate) << eol;
        os << "XTRAN\tYTRAN\tZTRAN\tXROT\tYROT\tZROT\tXSCALE\tYSCALE\tZSCALE" << eol;
        os << "INCHES\tINCHES\tINCHES\tDEGREES\tDEGREES\tDEGREES\tPERCENT\tPERCENT\tPERCENT" << eol;

        for (int j = 0; j < nFrame; ++j)
            os << M2I * (-c3d[j].point[i].x) << '\t'
               << M2I * c3d[j].point[i].z << '\t'
               << M2I * c3d[j].point[i].y << '\t'
               << "0\t0\t0\t100\t100\t100" << eol;
    }
}


static void
print_analog(C3D& c3d, ostream& os, const char *eol)
{
    if (c3d.header.nAnalogMeasurement == 0) // no analog data
        return; 

    os << "ANALOG" << eol;
    os << (c3d.header.nAnalogSample * c3d.header.frameRate) << ",Hz" << eol;

    C3DParameterChar *pc;
    pc = (C3DParameterChar*)c3d.getParameter("ANALOG:LABELS");
    if (pc == NULL) {
        cerr << "error: cannot fine required parameter: ANALOG:LABELS" << endl;
        exit(-1);
    }
    os << "Sample #";
    for (int i = 0; i < (int)pc->data.size(); ++i)
        os << ',' << remove_space(pc->data[i]);
    os << eol;

    pc = (C3DParameterChar*)c3d.getParameter("ANALOG:UNITS");
    if (pc == NULL) {
        cerr << "error: cannot fine required parameter: ANALOG:UNITS" << endl;
        exit(-1);
    }
    os << "Units:";
    for (int i = 0; i < (int)pc->data.size(); ++i)
        os << ',' << remove_space(pc->data[i]);
    os << eol;

    int nAnalogChannel = c3d.header.nAnalogMeasurement / c3d.header.nAnalogSample;
    for (int i = 0; i < c3d.header.lastFrame - c3d.header.firstFrame + 1; ++i)
        for (int j = 0; j < c3d.header.nAnalogSample; ++j) {
            os << (i * c3d.header.nAnalogSample + j + 1);
            for (int k = 0; k < nAnalogChannel; ++k)
                os << ',' << c3d[i].analog[j][k];
            os << eol;
        }
}



/*!
 *  This function assumes that the analog data is recorded as the following format:
    \verbatim
      frame_1 frame_2 ... frame_N
        frame := {plate_1 plate_2 ... plate_M}
        plate := {ForceX_12 ForceX_34 ForceY_14 ForceY_23 ForceZ_1 ForceZ_2 ForceZ_3 ForceZ_4}
    \endverbatim
 *
 *  Data of plate 'i' are recorded in channel CH((i-1)*8) ... CH(i*8-1).
 *
 *  This function is written for force plates in Aizu Univ.
 *  The following lengths about the force plates are given a priori.
 *
 *    - length between the center and the sensor on x-axis: 210mm
 *    - length between the center and the sensor on y-axis: 350mm
 *    - height from the sensor to the surface of the plate: 75mm
 *    
 */
static void
print_force(C3D& c3d, ostream& os, const char *eol)
{
    using namespace boost;

    C3DParameterInt *pi;
    pi = (C3DParameterInt*)c3d.getParameter("FORCE_PLATFORM:USED");
    if (pi == NULL) {
        cerr << "error: cannot fine required parameter: FORCE_PLATFORM:USED" << endl;
        exit(-1);
    }
    int nPlate = pi->data[0];

    C3DParameterFloat *pf;
    pf = (C3DParameterFloat*)c3d.getParameter("FORCE_PLATFORM:CORNERS");
    if (pf == NULL) {
        cerr << "error: cannot fine required parameter: FORCE_PLATFORM:CORNERS" << endl;
        exit(-1);
    }
    os << "FORCE PLATES" << eol;
    os << (c3d.header.nAnalogSample * c3d.header.frameRate) << ",Hz" << eol;
    os << ",Corner 1,,,Corner 2,,,Corner 3,,,Corner 4" << eol;
    os << "Plate#,X,Y,Z,X,Y,Z,X,Y,Z,X,Y,Z" << eol;
    for (int i = 0; i < nPlate; ++i) {
        os << i + 1 << ",";
        for (int j = 0; j < 12; ++j)
            os << pf->data[i * 12 + j] << (j == 11 ? eol : ",");
    }

    os << eol << ",";
    for (int i = 0; i < nPlate; ++i)
        os << "Force Plate " << i + 1 << ",,,,,,,,,,,,";
    os << eol << "Sample #";
    for (int i = 0; i < nPlate; ++i)
        os << ",COP:X,COP:Y,COP:Z,Ref:X,Ref:Y,Ref:Z,Force:X,Force:Y,Force:Z,Moment:X,Moment:Y,Moment:Z";
    os << eol << "Units:";
    for (int i = 0; i < nPlate; ++i)
        os << ",mm,mm,mm,mm,mm,mm,N,N,N,Nmm,Nmm,Nmm";
    os << eol;

    const float TH = 0.001;
    const float Ex = 210;
    const float Ey = 350;
    const float Ez = 75;
    float ad[8];
    enum {X12 = 0, X34, Y14, Y23, Z1, Z2, Z3, Z4};

    for (int i = 0; i < c3d.header.lastFrame - c3d.header.firstFrame + 1; ++i)
        for (int j = 0; j < c3d.header.nAnalogSample; ++j) {
            os << (i * c3d.header.nAnalogSample + j + 1);
            for (int k = 0; k < nPlate; ++k) {
                for (int l = 0; l < 8; ++l) {
                    int idx = c3d.findLabelIndex("ANALOG:LABELS", str(format("CH%1%") % (k * 8 + l + 1)));
                    ad[l] = c3d[i].analog[j][idx];
                }

                float fx, fy, fz, mx, my, mz, ax, ay, rx, ry, mmz;
                rx = (pf->data[k * 12 + 0] + pf->data[k * 12 + 3]) / 2; // center of plate
                ry = (pf->data[k * 12 + 4] + pf->data[k * 12 + 7]) / 2; // center of plate
                fx = ad[X12] + ad[X34];
                fy = -ad[Y14] - ad[Y23];
                fz = -ad[Z1] - ad[Z2] - ad[Z3] - ad[Z4];
                mx = Ey * (-ad[Z1] - ad[Z2] + ad[Z3] + ad[Z4]);
                my = Ex * (ad[Z1] + ad[Z4] - ad[Z2] - ad[Z3]);
                mz = Ey * (-ad[X12] + ad[X34]) + Ex * (ad[Y14] - ad[Y23]);
                if (fz > TH) {
                    ax = (fx * Ez - my) / fz;
                    ay = (fy * Ez - mx) / fz;
                    os << "," << rx + ax << "," << ry + ay << ",0,";
                } else {
                    ax = ay = 0.0;
                    os << ",,,,";
                }
                mmz = mz - fy * ax + fx * ay;
                os << rx << "," << ry << ",0,"
                   << fx << "," << fy << "," << fz << ","
                   << mx << "," << my << "," << mz;
            }
            os << eol;
        }
}


template<class T> void
print_parameter(T *pr)
{
    if (pr->nDim == 0)
        cout << "\n  " << pr->data[0];
    else if (pr->nDim == 1) {
        cout << "\n ";
        for (int i = 0; i < pr->dim[0]; ++i)
            cout << ' ' << pr->data[i];
    } else if (pr->nDim == 2) {
        for (int i = 0; i < pr->dim[1]; ++i) {
            cout << "\n ";
            for (int j = 0; j < pr->dim[0]; ++j)
                cout << ' ' << pr->data[i * pr->dim[0] + j];
        }
    } else if (pr->nDim == 3) {
        for (int i = 0; i < pr->dim[2]; ++i) {
            if (i != 0)
                cout << "\n";
            for (int j = 0; j < pr->dim[1]; ++j) {
                cout << "\n ";
                for (int k = 0; k < pr->dim[0]; ++k)
                    cout << ' ' << pr->data[(i * pr->dim[1] + j) * pr->dim[0] + k];
            }
        }
    } else
        cerr << "*** print_data() for nDim == " << pr->nDim << " is not implemented yet..." << endl;
}

static void
print_parameter(C3DParameterChar *pr)
{
    if (pr->nDim == 0 || pr->nDim == 1)
        cout << "\n  " << pr->data[0];
    else if (pr->nDim == 2)
        for (int i = 0; i < pr->dim[1]; ++i)
            cout << "\n  " << pr->data[i];
    else if (pr->nDim == 3) {
        for (int i = 0; i < pr->dim[2]; ++i) {
            if (i != 0)
                cout << "\n";
            for (int j = 0; j < pr->dim[1]; ++j)
                cout << "\n  " << pr->data[i * pr->dim[1] + j];
        }
    } else
        cerr << "*** print_data() for nDim == " << pr->nDim << " is not implemented yet..." << endl;
}


static void
print_parameter_unsigned(C3DParameterInt *pr)
{
    if (pr->nDim == 0)
        cout << "\n  " << (unsigned short)(pr->data[0]);
    else if (pr->nDim == 1) {
        cout << "\n ";
        for (int i = 0; i < pr->dim[0]; ++i)
            cout << ' ' << (unsigned short)(pr->data[i]);
    } else if (pr->nDim == 2) {
        for (int i = 0; i < pr->dim[1]; ++i) {
            cout << "\n ";
            for (int j = 0; j < pr->dim[0]; ++j)
                cout << ' ' << (unsigned short)(pr->data[i * pr->dim[0] + j]);
        }
    } else if (pr->nDim == 3) {
        for (int i = 0; i < pr->dim[2]; ++i) {
            if (i != 0)
                cout << "\n";
            for (int j = 0; j < pr->dim[1]; ++j) {
                cout << "\n ";
                for (int k = 0; k < pr->dim[0]; ++k)
                    cout << ' ' << (unsigned short)(pr->data[(i * pr->dim[1] + j) * pr->dim[0] + k]);
            }
        }
    } else
        cerr << "*** print_data() for nDim == " << pr->nDim << " is not implemented yet..." << endl;
}


static string
remove_space(const string& str)
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

//EOF
