
#ifndef ADDRESS_H
#define ADDRESS_H

#include string

/**
  * class Address
  * @class Address
  * @brief { Address is a abstraction which holds the address information of a
  * person. }
  * @details { }
  */

class Address
{
public:

  // Constructors/Destructors
  //  

  // Static Public attributes
  //  

  // Public attributes
  //  

  // @note { e.g. "Somethingstreet 17a" }
  string m_street;
  // @note { e.g. "c/o Mr. X" }
  string m_optional;
  // @note { e.g. "01234567890" }
  int m_zip;
  // @note { e.g. "Tokyo" }
  string m_city;
  // @note { e.g. "Japan" }
  string m_country;
  // @note { e.g. "Toyko-to" }
  string m_state;

  // Public attribute accessor methods
  //  


  // Public attribute accessor methods
  //  


  /**
   * Set the value of m_street
   * @note { e.g. "Somethingstreet 17a" }
   * @param new_var the new value of m_street
   */
  void setStreet ( string new_var );

  /**
   * Get the value of m_street
   * @note { e.g. "Somethingstreet 17a" }
   * @return the value of m_street
   */
  string getStreet ( );


  /**
   * Set the value of m_optional
   * @note { e.g. "c/o Mr. X" }
   * @param new_var the new value of m_optional
   */
  void setOptional ( string new_var );

  /**
   * Get the value of m_optional
   * @note { e.g. "c/o Mr. X" }
   * @return the value of m_optional
   */
  string getOptional ( );


  /**
   * Set the value of m_zip
   * @note { e.g. "01234567890" }
   * @param new_var the new value of m_zip
   */
  void setZip ( int new_var );

  /**
   * Get the value of m_zip
   * @note { e.g. "01234567890" }
   * @return the value of m_zip
   */
  int getZip ( );


  /**
   * Set the value of m_city
   * @note { e.g. "Tokyo" }
   * @param new_var the new value of m_city
   */
  void setCity ( string new_var );

  /**
   * Get the value of m_city
   * @note { e.g. "Tokyo" }
   * @return the value of m_city
   */
  string getCity ( );


  /**
   * Set the value of m_country
   * @note { e.g. "Japan" }
   * @param new_var the new value of m_country
   */
  void setCountry ( string new_var );

  /**
   * Get the value of m_country
   * @note { e.g. "Japan" }
   * @return the value of m_country
   */
  string getCountry ( );


  /**
   * Set the value of m_state
   * @note { e.g. "Toyko-to" }
   * @param new_var the new value of m_state
   */
  void setState ( string new_var );

  /**
   * Get the value of m_state
   * @note { e.g. "Toyko-to" }
   * @return the value of m_state
   */
  string getState ( );


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

#endif // ADDRESS_H
