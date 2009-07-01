
#ifndef EQUIPMENT_H
#define EQUIPMENT_H

#include string
#include vector



/**
  * class Equipment
  * @brief {Equipment can be all kind of things which is used or worn by a person.
  * }
  * @details {Equipment can be all kind of things which is either used or work by a
  * person. These things can include a force measuring system, clothing etc.}
  */

/******************************* Abstract Class ****************************
Equipment does not have any pure virtual methods, but its author
  defined it as an abstract class, so you should not use it directly.
  Inherit from it instead and create only objects from the derived classes
*****************************************************************************/

class Equipment
{
public:

  // Constructors/Destructors
  //  

  // Static Public attributes
  //  

  // Public attributes
  //  

  // @note { e.g. "" }
  string m_name;
  // @note { e.g. "" }
  string m_description;

  // Public attribute accessor methods
  //  


  // Public attribute accessor methods
  //  


  /**
   * Set the value of m_name
   * @note { e.g. "" }
   * @param new_var the new value of m_name
   */
  void setName ( string new_var );

  /**
   * Get the value of m_name
   * @note { e.g. "" }
   * @return the value of m_name
   */
  string getName ( );


  /**
   * Set the value of m_description
   * @note { e.g. "" }
   * @param new_var the new value of m_description
   */
  void setDescription ( string new_var );

  /**
   * Get the value of m_description
   * @note { e.g. "" }
   * @return the value of m_description
   */
  string getDescription ( );


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

#endif // EQUIPMENT_H
