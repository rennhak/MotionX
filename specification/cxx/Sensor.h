
#ifndef SENSOR_H
#define SENSOR_H

#include string
#include vector



/**
  * class Sensor
  */

class Sensor
{
public:

  // Constructors/Destructors
  //  

  // Static Public attributes
  //  

  // Public attributes
  //  


  // Public attribute accessor methods
  //  


  // Public attribute accessor methods
  //  


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

  // @note { e.g. "INCH" }
  string m_unit;
  // @note { e.g. Left Sternum, 2 cm above x }
  string m_placement;
public:


  // Private attribute accessor methods
  //  

private:

public:


  // Private attribute accessor methods
  //  


  /**
   * Set the value of m_unit
   * @note { e.g. "INCH" }
   * @param new_var the new value of m_unit
   */
  void setUnit ( string new_var );

  /**
   * Get the value of m_unit
   * @note { e.g. "INCH" }
   * @return the value of m_unit
   */
  string getUnit ( );


  /**
   * Set the value of m_placement
   * @note { e.g. Left Sternum, 2 cm above x }
   * @param new_var the new value of m_placement
   */
  void setPlacement ( string new_var );

  /**
   * Get the value of m_placement
   * @note { e.g. Left Sternum, 2 cm above x }
   * @return the value of m_placement
   */
  string getPlacement ( );

private:



};

#endif // SENSOR_H
