/*! \file
 *  \author KUDOH Shunsuke
 *  $Id: c3d.h 923 2009-06-03 12:53:38Z shun $
 */

#ifndef _C3D_H_
#define _C3D_H_

#include <fstream>
#include <string>
#include <vector>
#include "kdh_error.h"

//
// header section
//
struct C3DHeaderSection {
    short ptrToParameterSection;
    short nPoint;
    short nAnalogMeasurement;
    short firstFrame;
    short lastFrame;
    short maxInterpolationGap;
    float scaleFactor;
    short ptrToDataSection;
    short nAnalogSample;
    float frameRate;
};

//
// parameter format (parameter section)
//
struct C3DParameter {
    char id;
    std::string name;
    char type;
    unsigned char nDim;
    std::vector<unsigned char> dim;
    std::string description;

    enum DataType {CHAR = -1, INT1 = 1, INT2 = 2, FLOAT = 4};
};


struct C3DParameterChar : public C3DParameter {
    std::vector<std::string> data;
};


struct C3DParameterInt : public C3DParameter {
    std::vector<short> data;
};


struct C3DParameterFloat : public C3DParameter {
    std::vector<float> data;
};


//
//  group format (parameter section)
//
struct C3DGroup {
    char id;
    std::string name;
    std::string description;
    std::vector<C3DParameter*> parameter;

    size_t size() const                 {return parameter.size();}
    C3DParameter* operator[](int n)     {return parameter[n];}
};


//
//  parameter section
//
struct C3DParameterSection {
    char nBlock;
    char processorType;
    std::vector<C3DGroup*> group;

    size_t size() const                  {return group.size();}
    C3DGroup* operator[](int n) const    {return group[n];}
};


//
// point data (data frame)
//
struct C3DPoint {
    float x, y, z;
    unsigned char camera;
    float residual;
};


//
// data frame
//
struct C3DFrame {
    std::vector<C3DPoint> point;
    std::vector<std::vector<float> > analog;
};


class C3D {
public:
    C3D();

    C3DHeaderSection header;
    C3DParameterSection parameter;
    std::vector<C3DFrame> frame;

    bool load(const std::string& fname);
    bool load(std::istream& is);

    bool write(const std::string& fname);
    bool write(std::ostream& os);

    C3DFrame& operator[](int n)                 {return frame[n];}
    const C3DFrame& operator[](int n) const     {return frame[n];}

    C3DParameter *getParameter(const std::string&);
    int findLabelIndex(const std::string&, const std::string&);

    std::string errorMessage() const                 {return mError.message();}

    enum ProcessorType {
        Intel = 1,
        DEC = 2,
        MIPS = 3,
    };
    enum DataFormat {Integer, Floating};

    int err;
    std::string msg;

private:
    bool readHeader(std::istream&);
    bool readParameter(std::istream&);
    C3DGroup *readParameterGroupFormat(std::istream&, int*);
    C3DParameter *readParameterParameterFormat(std::istream&, int*);
    bool readData(std::istream&);
    std::string removeSpace(const std::string&);
    char readChar(std::istream&);
    short readInt(std::istream&);
    float readFloat(std::istream&);
    int convertIntMipsToIntel(int);
    float convertFloatDecToIntel(float);
    float convertFloatMIPSToIntel(float);

    int mCntByte;
    int mProcType;
    int mFormat;

    enum ErrorId {
        NoError = -1, CannotOpenFile, NotC3DFile, UnknownProcessorType,
        InvalidData1, InvalidData2, NoRequiredParameter, InvalidDataType,
    };
    KdhError mError;
};

#endif//_C3D_H_
//EOF
