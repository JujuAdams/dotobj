<h1 align="center">dotobj 5.0.0</h1>

<p align="center">.obj/.mtl loader, written in native GML, for GameMaker Studio 2.3</p>

<p align="center"><b>@jujuadams</b></p>

&nbsp;

Lightweight .obj/.mtl 3D model loader written in native GML. Can load from external files or from buffers. This example does not show off complex renderering or PBR, it only demonstrates the loading capabilities of the library.

Details on the .obj format can be found here: http://paulbourke.net/dataformats/obj/

&nbsp;

<p align="center"><img src="https://raw.githubusercontent.com/JujuAdams/dotobj/master/dotobj_5_0_0_sponza.png" style="display:block; margin:auto;"><i>Look! It's Sponza! In GameMaker!</i></p>

&nbsp;

**dotobj currently supports:**

1. Per vertex position, texture coordinates, and normals

2. Materials and material libraries

3. Groups and objects

4. Vertex colours - *(not in the official .obj spec, but some editors can export them)*

5. UV flipping and winding-order reversal to handle engine quirks

6. N-gon faces

&nbsp;

**How do I import dotobj into my game?**

GameMaker Studio 2.3.0 allows you to import assets, including scripts and shaders, directly into your project via the "Local Package" system. From the [Releases](https://github.com/JujuAdams/dotobj/releases/) tab for this repo, download the .yymps file for the latest version. In the GMS2 IDE, load up your project and click on "Tools" on the main window toolbar. Select "Import Local Package" from the drop-down menu then import all scripts from the package.

&nbsp;

**Please note that dotobj doesn't support the following features:**

1. Smoothing groups

*Not a priority since you can usually bake normals on export, but it'd be useful to have regardless.*

2. Separate in-file LOD

*Not sure how often this gets used. Probably possible to implement if requested.*

3. Line primitives

*Line primitives are mostly used for visualisation in editors rather than for actual game rendering. It's possible to parse line primitives and output that, but it's not a priority.*

4. Freeform curve/surface geometry (NURBs/Bezier curves etc.)

*Rare to see this in gamedev and getting GameMaker to generate surfaces is not going to be a pleasant process. This will probably never be implemented.*
