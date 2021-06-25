## LANGUAGE FOR SCENE CREATION

Here are reported all the keyowrds needed to create a scene from a text file. For a quick and easy tutorial on how to create images open the [README.md](https://github.com/DanieleZambetti97/ProjectMoana/blob/master/README.md) file.

### Generic words

- `NEW`: used for constructors. 
- `FLOAT`: used for identifying floating point variables;

### Materials & Pigments

- `MATERIAL`: defines a new material, fundamental for creating shapes;
- a `MATERIAL` has two components:
  - a **diffusive** one that can be `DIFFUSE` (for a diffuse effect) of `SPECULAR` (for a specular effect);
  - a **emissive** one that can only be `UNIFORM`.
- both of the components are defined by a **pigment** that can be:
  - `UNIFORM` for a uniform color;
  - `CHECKERED` for a checkered combination of two colors;
  - `IMAGE` to reporduce a image on any shape;

### Shapes

- `PLANE` defined by a `(material, transformation)`;
- `SPHERE` defined by a `(material, transformation)`;
- `AABOX` (Axis ALigned Box) defined by `(material, transformation)`;

By default, shapes are generated in the center of the image; moving them requires a transformation.

### Transformations

All the transformation are described by matrixes.

- `IDENTITY` is the identical transformation;
- `TRANSLATION` is a translation of a vector `[x, y, z]`;
- `ROTATION_X` is the rotation around the X axis by an angle \alpha in degrees `ROTATION_X(\alpha)`;
- `ROTATION_Y` is the rotation around the X axis by an angle \beta in degrees `ROTATION_Y(\beta)`;
- `ROTATION_Z` is the rotation around the X axis by an angle \gamma in degrees `ROTATION_Y(\gamma)`;
- `SCALING` scales any shape in every dimension by a vector `[x, y, z]`;

### Cameras

The observer is described by a Camera:

- `CAMERA` that can be:
  - `ORTHOGONAL` for a orthogonal view;
  - `PERSPECTIVE` for a perspective view.

Any camera is created with `CAMERA(ORTHOGONAL/PERSPECTIVE, transformation)`.
