
#ifndef PERSON_H
#define PERSON_H

#include string
#include vector



/**
  * class Person
  * @class Person
  * @brief { The Person class is a representation of a natural person and all its
  * data. }
  * @details { The Person class represents a abstraction of all possible data which
  * a natural person can have. }
  */

class Person
{
public:

  // Constructors/Destructors
  //  

  // Static Public attributes
  //  

  // Public attributes
  //  

  // @note { e.g. "Bjoern" }
  string m_firstName;
  // @note { e.g. "J.C." }
  string m_middleName;
  // @note { e.g. "Rennhak" }
  string m_lastName;
  // @note { e.g. "Tokyo University" }
  string m_organization;
  // @note { e.g. "TRUE" is Male, "FALSE" is FEMALE }
  bool m_gender;

  // Public attribute accessor methods
  //  


  // Public attribute accessor methods
  //  


  /**
   * Set the value of m_firstName
   * @note { e.g. "Bjoern" }
   * @param new_var the new value of m_firstName
   */
  void setFirstName ( string new_var );

  /**
   * Get the value of m_firstName
   * @note { e.g. "Bjoern" }
   * @return the value of m_firstName
   */
  string getFirstName ( );


  /**
   * Set the value of m_middleName
   * @note { e.g. "J.C." }
   * @param new_var the new value of m_middleName
   */
  void setMiddleName ( string new_var );

  /**
   * Get the value of m_middleName
   * @note { e.g. "J.C." }
   * @return the value of m_middleName
   */
  string getMiddleName ( );


  /**
   * Set the value of m_lastName
   * @note { e.g. "Rennhak" }
   * @param new_var the new value of m_lastName
   */
  void setLastName ( string new_var );

  /**
   * Get the value of m_lastName
   * @note { e.g. "Rennhak" }
   * @return the value of m_lastName
   */
  string getLastName ( );


  /**
   * Set the value of m_organization
   * @note { e.g. "Tokyo University" }
   * @param new_var the new value of m_organization
   */
  void setOrganization ( string new_var );

  /**
   * Get the value of m_organization
   * @note { e.g. "Tokyo University" }
   * @return the value of m_organization
   */
  string getOrganization ( );


  /**
   * Set the value of m_gender
   * @note { e.g. "TRUE" is Male, "FALSE" is FEMALE }
   * @param new_var the new value of m_gender
   */
  void setGender ( bool new_var );

  /**
   * Get the value of m_gender
   * @note { e.g. "TRUE" is Male, "FALSE" is FEMALE }
   * @return the value of m_gender
   */
  bool getGender ( );


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

#endif // PERSON_H
