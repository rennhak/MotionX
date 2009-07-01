
#ifndef FRAME_H
#define FRAME_H

#include string
#include vector



/**
  * class Frame
  */

class Frame
{
public:

  // Constructors/Destructors
  //  

  // Static Public attributes
  //  

  // Public attributes
  //  

  // @note { e.g. "Thu Jul  2 00:54:22 JST 2009" }
  string m_timestamp;
  // @note { e.g. 1246463811 }
  unsigned int m_epoch;

  // Public attribute accessor methods
  //  


  // Public attribute accessor methods
  //  


  /**
   * Set the value of m_timestamp
   * @note { e.g. "Thu Jul  2 00:54:22 JST 2009" }
   * @param new_var the new value of m_timestamp
   */
  void setTimestamp ( string new_var );

  /**
   * Get the value of m_timestamp
   * @note { e.g. "Thu Jul  2 00:54:22 JST 2009" }
   * @return the value of m_timestamp
   */
  string getTimestamp ( );


  /**
   * Set the value of m_epoch
   * @note { e.g. 1246463811 }
   * @param new_var the new value of m_epoch
   */
  void setEpoch ( unsigned int new_var );

  /**
   * Get the value of m_epoch
   * @note { e.g. 1246463811 }
   * @return the value of m_epoch
   */
  unsigned int getEpoch ( );


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

#endif // FRAME_H
