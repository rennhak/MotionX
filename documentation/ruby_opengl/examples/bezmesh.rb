#
#/* Copyright (c) Mark J. Kilgard, 1994. */
#
#/**
# * (c) Copyright 1993, Silicon Graphics, Inc.
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
# * OpenGL(TM) is a trademark of Silicon Graphics, Inc.
# */
#/*  bezsurf.c
# *  This program renders a lighted, filled Bezier surface,
# *  using two-dimensional evaluators.
# */

require "opengl"
require "glut"

$ctrlpoints = [
    [
        [-1.5, -1.5, 4.0],
        [-0.5, -1.5, 2.0],
        [0.5, -1.5, -1.0],
        [1.5, -1.5, 2.0]],
    [
        [-1.5, -0.5, 1.0],
        [-0.5, -0.5, 3.0],
        [0.5, -0.5, 0.0],
        [1.5, -0.5, -1.0]],
    [
        [-1.5, 0.5, 4.0],
        [-0.5, 0.5, 0.0],
        [0.5, 0.5, 3.0],
        [1.5, 0.5, 4.0]],
    [
        [-1.5, 1.5, -2.0],
        [-0.5, 1.5, -2.0],
        [0.5, 1.5, 0.0],
        [1.5, 1.5, -1.0]]
];

def initlights
    ambient = [0.2, 0.2, 0.2, 1.0];
    position = [0.0, 0.0, 2.0, 1.0];
    mat_diffuse = [0.6, 0.6, 0.6, 1.0];
    mat_specular = [1.0, 1.0, 1.0, 1.0];
    mat_shininess = [50.0];

    GL::Enable(GL::LIGHTING);
    GL::Enable(GL::LIGHT0);

    GL::Light(GL::LIGHT0, GL::AMBIENT, ambient);
    GL::Light(GL::LIGHT0, GL::POSITION, position);

    GL::Material(GL::FRONT, GL::DIFFUSE, mat_diffuse);
    GL::Material(GL::FRONT, GL::SPECULAR, mat_specular);
    GL::Material(GL::FRONT, GL::SHININESS, mat_shininess);
end

display = proc {
    GL::Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT);
    GL::PushMatrix();
    GL::Rotate(85.0, 1.0, 1.0, 1.0);
    GL::EvalMesh2(GL::FILL, 0, 20, 0, 20);
    GL::PopMatrix();
    GL::Flush();
}

def myinit
    GL::ClearColor(0.0, 0.0, 0.0, 1.0);
    GL::Enable(GL::DEPTH_TEST);
    GL::Map2d(GL::MAP2_VERTEX_3, 0, 1, 3, 4,
        0, 1, 12, 4, $ctrlpoints.flatten);
    GL::Enable(GL::MAP2_VERTEX_3);
    GL::Enable(GL::AUTO_NORMAL);
    GL::Enable(GL::NORMALIZE);
    GL::MapGrid2d(20, 0.0, 1.0, 20, 0.0, 1.0);
    initlights();      # /* for lighted version only */
end

myReshape = proc {|w, h|
    GL::Viewport(0, 0, w, h);
    GL::MatrixMode(GL::PROJECTION);
    GL::LoadIdentity();
    if (w <= h)
        GL::Ortho(-4.0, 4.0, -4.0 * h / w, 4.0 * h / w, -4.0, 4.0);
    else
        GL::Ortho(-4.0 * w / h, 4.0 * w / h, -4.0, 4.0, -4.0, 4.0);
    end
    GL::MatrixMode(GL::MODELVIEW);
    GL::LoadIdentity();
}

    GLUT::Init();
    GLUT::InitDisplayMode(GLUT::SINGLE | GLUT::RGB | GLUT::DEPTH);
    GLUT::CreateWindow($0);
    myinit();
    GLUT::ReshapeFunc(myReshape);
    GLUT::DisplayFunc(display);
    GLUT::MainLoop();
