#/*
# * Copyright (c) 1993-1997, Silicon Graphics, Inc.
# * ALL RIGHTS RESERVED 
# * Permission to use, copy, modify, and distribute this software for 
# * any purpose and without fee is hereby granted, provided that the above
# * copyright notice appear in all copies and that both the copyright notice
# * and this permission notice appear in supporting documentation, and that 
# * the name of Silicon Graphics, Inc. not be used in advertising
# * or publicity pertaining to distribution of the software without specific,
# * written prior permission. 
# *
# * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
# * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
# * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
# * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
# * GRAPHICS, INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
# * SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
# * KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING WITHOUT LIMITATION,
# * LOSS OF PROFIT, LOSS OF USE, SAVINGS OR REVENUE, OR THE CLAIMS OF
# * THIRD PARTIES, WHETHER OR NOT SILICON GRAPHICS, INC.  HAS BEEN
# * ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
# * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
# * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
# * 
# * US Government Users Restricted Rights 
# * Use, duplication, or disclosure by the Government is subject to
# * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
# * (c)(1)(ii) of the Rights in Technical Data and Computer Software
# * clause at DFARS 252.227-7013 and/or in similar or successor
# * clauses in the FAR or the DOD or NASA FAR Supplement.
# * Unpublished-- rights reserved under the copyright laws of the
# * United States.  Contractor/manufacturer is Silicon Graphics,
# * Inc., 2011 N.  Shoreline Blvd., Mountain View, CA 94039-7311.
# *
# * OpenGL(R) is a registered trademark of Silicon Graphics, Inc.
# */
#
#/*
# *  varray.c
# *  This program demonstrates vertex arrays.
# */

require "opengl"
require "glut"

POINTER=1
INTERLEAVED=2

DRAWARRAY=1
ARRAYELEMENT=2
DRAWELEMENTS=3

$setupMethod = POINTER;
$derefMethod = DRAWARRAY;

def setupPointers
   $vertices = [25, 25,
                       100, 325,
                       175, 25,
                       175, 325,
                       250, 25,
                       325, 325].pack("i*");
   $colors = [1.0, 0.2, 0.2,
                       0.2, 0.2, 1.0,
                       0.8, 1.0, 0.2,
                       0.75, 0.75, 0.75,
                       0.35, 0.35, 0.35,
                       0.5, 0.5, 0.5].pack("f*");

   GL.EnableClientState(GL::VERTEX_ARRAY);
   GL.EnableClientState(GL::COLOR_ARRAY);

   GL.VertexPointer(2, GL::INT, 0, $vertices);
   GL.ColorPointer(3, GL::FLOAT, 0, $colors);
end

def  setupInterleave
   $intertwined =
      [1.0, 0.2, 1.0, 100.0, 100.0, 0.0,
       1.0, 0.2, 0.2, 0.0, 200.0, 0.0,
       1.0, 1.0, 0.2, 100.0, 300.0, 0.0,
       0.2, 1.0, 0.2, 200.0, 300.0, 0.0,
       0.2, 1.0, 1.0, 300.0, 200.0, 0.0,
       0.2, 0.2, 1.0, 200.0, 100.0, 0.0].pack("f*");
   
   GL.InterleavedArrays(GL::C3F_V3F, 0, $intertwined);
end

def init
   GL.ClearColor(0.0, 0.0, 0.0, 0.0);
   GL.ShadeModel(GL::SMOOTH);
   setupPointers();
end

display = proc {
   GL.Clear(GL::COLOR_BUFFER_BIT);

   if ($derefMethod == DRAWARRAY) 
      GL.DrawArrays(GL::TRIANGLES, 0, 6);
   elsif ($derefMethod == ARRAYELEMENT)
      GL.Begin(GL::TRIANGLES);
      GL.ArrayElement(2);
      GL.ArrayElement(3);
      GL.ArrayElement(5);
      GL.End();
   elsif ($derefMethod == DRAWELEMENTS)
      $indices = [0, 1, 3, 4].pack("I*")
      GL.DrawElements(GL::POLYGON, 4, GL::UNSIGNED_INT, $indices);
   end
   GL.Flush();
}

reshape = proc {|w, h|
   GL.Viewport(0, 0, w, h);
   GL.MatrixMode(GL::PROJECTION);
   GL.LoadIdentity();
   GLU.Ortho2D(0.0, w, 0.0, h);
}

#/* ARGSUSED2 */
mouse = proc {|button, state, x, y|
   case (button)
      when GLUT::LEFT_BUTTON
         if (state == GLUT::DOWN)
            if ($setupMethod == POINTER)
               $setupMethod = INTERLEAVED;
               setupInterleave();
            elsif ($setupMethod == INTERLEAVED)
               $setupMethod = POINTER;
               setupPointers();
            end
            GLUT.PostRedisplay();
         end
      when GLUT::MIDDLE_BUTTON,GLUT::RIGHT_BUTTON
         if (state == GLUT::DOWN)
            if ($derefMethod == DRAWARRAY) 
               $derefMethod = ARRAYELEMENT;
            elsif ($derefMethod == ARRAYELEMENT) 
               $derefMethod = DRAWELEMENTS;
            elsif ($derefMethod == DRAWELEMENTS) 
               $derefMethod = DRAWARRAY;
            end
            GLUT.PostRedisplay();
         end
   end
}

#/* ARGSUSED1 */
keyboard = proc {|key, x, y|
   case (key)
      when 27
         exit(0);
   end
}

   GLUT.Init();
   GLUT.InitDisplayMode(GLUT::SINGLE | GLUT::RGB);
   GLUT.InitWindowSize(350, 350);
   GLUT.InitWindowPosition(100, 100);
   GLUT.CreateWindow()
   init();
   GLUT.DisplayFunc(display); 
   GLUT.ReshapeFunc(reshape);
   GLUT.MouseFunc(mouse);
   GLUT.KeyboardFunc(keyboard);
   GLUT.MainLoop();
