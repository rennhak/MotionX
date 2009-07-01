
#ifndef PICTURE_H
#define PICTURE_H
#include "Media.h"

#include string

/**
  * class Picture
  */

class Picture : virtual public Media
{
public:

  // Constructors/Destructors
  //  

  // Static Public attributes
  //  

  // Public attributes
  //  

  // @note {e.g. 124 in px}
  int m_height;
  // @note { e.g. 124 in px}
  int m_width;

  // Public attribute accessor methods
  //  


  // Public attribute accessor methods
  //  


  /**
   * Set the value of m_height
   * @note {e.g. 124 in px}
   * @param new_var the new value of m_height
   */
  void setHeight ( int new_var );

  /**
   * Get the value of m_height
   * @note {e.g. 124 in px}
   * @return the value of m_height
   */
  int getHeight ( );


  /**
   * Set the value of m_width
   * @note { e.g. 124 in px}
   * @param new_var the new value of m_width
   */
  void setWidth ( int new_var );

  /**
   * Get the value of m_width
   * @note { e.g. 124 in px}
   * @return the value of m_width
   */
  int getWidth ( );


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

#endif // PICTURE_H
