<h1 align="center">dotobj 3.0.0</h1>

### @jujuadams, platypus model by @r0wan_dev

Lightweight .obj 3D model loader written in native GML. Can load from external files or from buffers.

Details on the .obj format can be found here: http://paulbourke.net/dataformats/obj/

&nbsp;

**dotobj currently supports:**

1. Position, texture coordinates. normals

2. Multiple vertex buffer output via .obj groups

3. UV flipping - *(for compatibility between DirectX and OpenGL)*

4. Vertex colours - *(not in the official .obj spec, but some editors can export them)*

5. n-gon faces

6. Custom vertex buffer formats

7. Winding-order reversal

&nbsp;

**Please note that dotobj doesn't support the following features:**

1. Materials

*Hopefully I'll implement materials soon. Adding support for all the exciting fancy things is something I want to do, but it'll require a lot of extra work around the importer. When you use materials, the main `dotobj_load()` script can no longer return a single vertex buffer, or even a simple array of vertex buffers. Each vertex buffer that gets created and returned has to be stored with extra data that describes the material used to render that vertex buffer.*

2. External texture map or .obj references

*See above. Allowing for loading assets from outside of GameMaker's texture pages will make development a lot easier, but it also makes the import process much less elegant.*

3. Separate in-file LOD

*Not sure how often this gets used, but see point 1. Requires a lot of structure around the core vertex buffer(s).*

4. Smoothing groups

*Not a priority since you can usually bake normals on export, but it'd be useful to have regardless.*

5. Line primitives

*Line primitives are mostly used for visualisation in editors rather than for actual game rendering. It's possible to parse line primitives and output that, but it's not a priority.*

6. Freeform curve/surface geometry (NURBs/Bezier curves etc.)

*Rare to see this in gamedev and getting GameMaker to generates surfaces is not going to be a pleasant process. This will probably never be implemented.*
