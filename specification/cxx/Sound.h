
#ifndef SOUND_H
#define SOUND_H
#include "Media.h"

#include string

/**
  * class Sound
  */

class Sound : virtual public Media
{
public:

  // Constructors/Destructors
  //  

  // Static Public attributes
  //  

  // Public attributes
  //  

  // @note {e.g. "44100" in Hz}
  int m_samplerate;
  // @note {e.g. "127.4" in s}
  float m_length;

  // Public attribute accessor methods
  //  


  // Public attribute accessor methods
  //  


  /**
   * Set the value of m_samplerate
   * @note {e.g. "44100" in Hz}
   * @param new_var the new value of m_samplerate
   */
  void setSamplerate ( int new_var );

  /**
   * Get the value of m_samplerate
   * @note {e.g. "44100" in Hz}
   * @return the value of m_samplerate
   */
  int getSamplerate ( );


  /**
   * Set the value of m_length
   * @note {e.g. "127.4" in s}
   * @param new_var the new value of m_length
   */
  void setLength ( float new_var );

  /**
   * Get the value of m_length
   * @note {e.g. "127.4" in s}
   * @return the value of m_length
   */
  float getLength ( );


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

#endif // SOUND_H
