#! /usr/bin/ruby -w
#

# = Libraries
require "opengl"
require "glut"


display = Proc.new {
   GL.Clear (GL::COLOR_BUFFER_BIT);

   GL.Color(1.0, 1.0, 1.0);
   GL.Begin(GL::POLYGON);
      # GL.Vertex(0.25, 0.25, 0.0);
   
   GL.End();

   GL.Flush();
}

def init
   GL.ClearColor(0.0, 0.0, 0.0, 0.0);

   GL.MatrixMode(GL::PROJECTION);
   GL.LoadIdentity();
   GL.Ortho(0.0, 1.0, 0.0, 1.0, -1.0, 1.0);
end

  
# Main Program flow
GLUT.Init
GLUT.InitDisplayMode(GLUT::SINGLE | GLUT::RGB);
GLUT.InitWindowSize(250, 250); 
GLUT.InitWindowPosition(100, 100);
GLUT.CreateWindow("Keypose extraction");
init();
GLUT.DisplayFunc( display ); 
GLUT.MainLoop();

