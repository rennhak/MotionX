/*! \file
 *  \author KUDOH Shunsuke
 *  $Id: kdh_error.h 478 2006-02-27 21:56:39Z shun $
 */
#ifndef _KDH_ERROR_H_
#define _KDH_ERROR_H_

#include <string>
#include <vector>

struct KdhErrorElement {
    int index;
    std::string message;

    KdhErrorElement()                                                           {}
    KdhErrorElement(int idx, const std::string& str) : index(idx), message(str) {}
};


class KdhError : public std::vector<KdhErrorElement> {
    int mId;
    std::string mMsg;
public:
    KdhError() : mId(-1)                         {}

    int index() const                           {return mId;}
    std::string message() const                 {return (mId >= 0 ? mMsg : std::string());}

    void setIndex(int idx)                      {mId = idx;}
    void setMessage(const std::string& str)     {mMsg = str;}
};


#endif//_KDH_ERROR_H_
