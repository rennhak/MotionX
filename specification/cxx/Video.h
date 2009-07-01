
#ifndef VIDEO_H
#define VIDEO_H
#include "Media.h"

#include string

/**
  * class Video
  */

class Video : virtual public Media
{
public:

  // Constructors/Destructors
  //  

  // Static Public attributes
  //  

  // Public attributes
  //  

  // @note {e.g. "1247.12"}
  float m_bitrate;
  // @note { e.g. "124.1" in s }
  float m_length;
  // @note { e.g. "800x600" in px }
  string m_resolution;

  // Public attribute accessor methods
  //  


  // Public attribute accessor methods
  //  


  /**
   * Set the value of m_bitrate
   * @note {e.g. "1247.12"}
   * @param new_var the new value of m_bitrate
   */
  void setBitrate ( float new_var );

  /**
   * Get the value of m_bitrate
   * @note {e.g. "1247.12"}
   * @return the value of m_bitrate
   */
  float getBitrate ( );


  /**
   * Set the value of m_length
   * @note { e.g. "124.1" in s }
   * @param new_var the new value of m_length
   */
  void setLength ( float new_var );

  /**
   * Get the value of m_length
   * @note { e.g. "124.1" in s }
   * @return the value of m_length
   */
  float getLength ( );


  /**
   * Set the value of m_resolution
   * @note { e.g. "800x600" in px }
   * @param new_var the new value of m_resolution
   */
  void setResolution ( string new_var );

  /**
   * Get the value of m_resolution
   * @note { e.g. "800x600" in px }
   * @return the value of m_resolution
   */
  string getResolution ( );


protected:

  // Static Protected attributes
  //  

  // Protected attributes
  //  

public:


  // Protected attribute accessor methods
  //  

protected:

public:


  // Protected attribute accessor methods
  //  

protected:


private:

  // Static Private attributes
  //  

  // Private attributes
  //  

public:


  // Private attribute accessor methods
  //  

private:

public:


  // Private attribute accessor methods
  //  

private:



};

#endif // VIDEO_H
