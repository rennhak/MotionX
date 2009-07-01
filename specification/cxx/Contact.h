
#ifndef CONTACT_H
#define CONTACT_H

#include string

/**
  * class Contact
  * @class Contact
  * @brief {Contact encapsulates everything beside an Address.}
  * @details {Contact stores everything beside addresses like email, fax, phone
  * etc.}
  */

class Contact
{
public:

  // Constructors/Destructors
  //  

  // Static Public attributes
  //  

  // Public attributes
  //  

  // @note {e.g. "bjoern@rennhak.de" }
  string m_email;
  // @note { e.g. "+81 (0) 3 123 456 789 / -ext 799" }
  string m_phone;
  // @note { e.g. "+81 (0) 3 123 456 789 / -ext 799" }
  string m_fax;
  // @note {e.g. "http://www.example.com" }
  string m_www;

  // Public attribute accessor methods
  //  


  // Public attribute accessor methods
  //  


  /**
   * Set the value of m_email
   * @note {e.g. "bjoern@rennhak.de" }
   * @param new_var the new value of m_email
   */
  void setEmail ( string new_var );

  /**
   * Get the value of m_email
   * @note {e.g. "bjoern@rennhak.de" }
   * @return the value of m_email
   */
  string getEmail ( );


  /**
   * Set the value of m_phone
   * @note { e.g. "+81 (0) 3 123 456 789 / -ext 799" }
   * @param new_var the new value of m_phone
   */
  void setPhone ( string new_var );

  /**
   * Get the value of m_phone
   * @note { e.g. "+81 (0) 3 123 456 789 / -ext 799" }
   * @return the value of m_phone
   */
  string getPhone ( );


  /**
   * Set the value of m_fax
   * @note { e.g. "+81 (0) 3 123 456 789 / -ext 799" }
   * @param new_var the new value of m_fax
   */
  void setFax ( string new_var );

  /**
   * Get the value of m_fax
   * @note { e.g. "+81 (0) 3 123 456 789 / -ext 799" }
   * @return the value of m_fax
   */
  string getFax ( );


  /**
   * Set the value of m_www
   * @note {e.g. "http://www.example.com" }
   * @param new_var the new value of m_www
   */
  void setWww ( string new_var );

  /**
   * Get the value of m_www
   * @note {e.g. "http://www.example.com" }
   * @return the value of m_www
   */
  string getWww ( );


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

#endif // CONTACT_H
