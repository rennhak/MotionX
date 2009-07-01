
#ifndef MEDIA_H
#define MEDIA_H

#include string
#include vector



/**
  * class Media
  * @class Media
  * @brief {Media is a abstract base class which represents many things related to
  * this motion capture session.}
  * @details {Media is a abstract base class which represents many things related to
  * this motion capture session. For instance  a Video, Picture, Sound files etc.}
  */

/******************************* Abstract Class ****************************
Media does not have any pure virtual methods, but its author
  defined it as an abstract class, so you should not use it directly.
  Inherit from it instead and create only objects from the derived classes
*****************************************************************************/

class Media
{
public:

  // Constructors/Destructors
  //  

  // Static Public attributes
  //  

  // Public attributes
  //  

  // @note { e.g. "Symphony Nr. III, D Minor" } 
  string m_name;
  // @note {e.g. "This is a musical piece by .... etc. etc."}
  string m_description;
  // @note {e.g. "Music_01.mp3" }
  string m_filename;
  // @note {e.g. "/my/location"}
  string m_path;
  // @note {e.g. "Base64 encoded payload" }
  string m_data;
  // @note {e.g. "MPEG Layer III"}
  string m_codec;

  // Public attribute accessor methods
  //  


  // Public attribute accessor methods
  //  


  /**
   * Set the value of m_name
   * @note { e.g. "Symphony Nr. III, D Minor" }
   * @param new_var the new value of m_name
   */
  void setName ( string new_var );

  /**
   * Get the value of m_name
   * @note { e.g. "Symphony Nr. III, D Minor" }
   * @return the value of m_name
   */
  string getName ( );


  /**
   * Set the value of m_description
   * @note {e.g. "This is a musical piece by .... etc. etc."}
   * @param new_var the new value of m_description
   */
  void setDescription ( string new_var );

  /**
   * Get the value of m_description
   * @note {e.g. "This is a musical piece by .... etc. etc."}
   * @return the value of m_description
   */
  string getDescription ( );


  /**
   * Set the value of m_filename
   * @note {e.g. "Music_01.mp3" }
   * @param new_var the new value of m_filename
   */
  void setFilename ( string new_var );

  /**
   * Get the value of m_filename
   * @note {e.g. "Music_01.mp3" }
   * @return the value of m_filename
   */
  string getFilename ( );


  /**
   * Set the value of m_path
   * @note {e.g. "/my/location"}
   * @param new_var the new value of m_path
   */
  void setPath ( string new_var );

  /**
   * Get the value of m_path
   * @note {e.g. "/my/location"}
   * @return the value of m_path
   */
  string getPath ( );


  /**
   * Set the value of m_data
   * @note {e.g. "Base64 encoded payload" }
   * @param new_var the new value of m_data
   */
  void setData ( string new_var );

  /**
   * Get the value of m_data
   * @note {e.g. "Base64 encoded payload" }
   * @return the value of m_data
   */
  string getData ( );


  /**
   * Set the value of m_codec
   * @note {e.g. "MPEG Layer III"}
   * @param new_var the new value of m_codec
   */
  void setCodec ( string new_var );

  /**
   * Get the value of m_codec
   * @note {e.g. "MPEG Layer III"}
   * @return the value of m_codec
   */
  string getCodec ( );


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

#endif // MEDIA_H
