## LANGUAGE FOR SCENE CREATION

Here are reported all the keyowrds needed to create a scene from a text file. For a quick and easy tutorial on how to create images open the [README.md](https://github.com/DanieleZambetti97/ProjectMoana/blob/master/README.md) file.

### Generic words

- `NEW`: used for constructors;
- `FLOAT`: used for identifying floating point variables;
- `INT`: used for identifying integer variables;
- `WIDTH`: used for identifying the width of the image;
- `HEIGHT`: used for identifying the height of the image. 

**Examples:**
```
FLOAT angle(180)
INT WIDTH(1280)
```

### Materials & Pigments

- `MATERIAL`: defines a new material, fundamental for creating shapes;
- a `MATERIAL` has two components:
  - a **diffusive** one that contains a *BRDF* `DIFFUSE` (for a diffuse effect) or `SPECULAR` (for a specular effect);
  - a **emissive** one that can only be `UNIFORM`.
- both of the components are defined by a **pigment** that can be:
  - `UNIFORM` for a uniform color;
  - `CHECKERED` for a checkered combination of two colors;
  - `IMAGE` to reporduce a image on any shape;

**Examples:**
```
MATERIAL material1(
        DIFFUSE(UNIFORM(<0., 0., 0.>)),
        UNIFORM(<0.5, 0.8, 1>)            
)

MATERIAL material2(
        SPECULAR(UNIFORM(<1., 0., .5>)),   
        UNIFORM(<0.5, 0.5, 0.5>)            
)

MATERIAL material_check(
        DIFFUSE(CHECKERED(<0.1, 0.5, 0.2>,
                        <0.1, 0.2, 0.1>, 3)),
        UNIFORM(<0, 0, 0>)
)

MATERIAL material_image(
        DIFFUSE(IMAGE("./images/my_image.pfm")),
        UNIFORM(<0, 0, 0>)
)
```

### Shapes

- `PLANE` defined by a `(material, transformation)`;
- `SPHERE` defined by a `(material, transformation)`;
- `AABOX` (Axis ALigned Box) defined by `(material, transformation)`;
- `LIGHTPOINT` (Shapes represent point light source for PL algorithm) defined by `(material, vector)`
By default, shapes are generated in the center of the image; moving them requires a transformation.

**Examples:**
```
PLANE (material1, TRANSLATION([0, 0, 500]) * ROTATION_Y(60) )

SPHERE(material2, TRANSLATION([1.5, 2, -0.5]) * SCALING([1.,1.5,1.]))

AABOX(material_image, TRANSLATION([-0.5,-1.7,-1.1]) * SCALING([1.,1.,1.]))
```

### Transformations

All the transformation are described by matrixes.

- `IDENTITY` is the identical transformation;
- `TRANSLATION` is a translation of a vector `[x, y, z]`;
- `ROTATION_X` is the rotation around the X axis by an angle alpha in degrees `ROTATION_X(alpha)`;
- `ROTATION_Y` is the rotation around the X axis by an angle beta in degrees `ROTATION_Y(beta)`;
- `ROTATION_Z` is the rotation around the X axis by an angle gamma in degrees `ROTATION_Y(gamma)`;
- `SCALING` scales any shape in every dimension by a vector `[x, y, z]`;

**Examples:**

The transformation in the shapes shown above.


### Cameras

The observer is described by a Camera:

- `CAMERA` that can be:
  - `ORTHOGONAL` for a orthogonal view;
  - `PERSPECTIVE` for a perspective view.

Any camera is created with `CAMERA(ORTHOGONAL/PERSPECTIVE, transformation)`.

**Examples**
```
CAMERA(ORTHOGONAL, TRANSLATION([-2, 0, 0]))                   # default aspect ratio width/height

CAMERA(ORTHOGONAL, TRANSLATION([-2, 0, 0]), a_ratio)          # specifying aspect ratio

CAMERA(PERSPECTIVE, distance, TRANSLATION([-2, 0, 0]))             # default aspect ratio width/height

CAMERA(PERSPECTIVE, distance, TRANSLATION([-2, 0, 0]), a_ratio )   # specifying aspect ratio
```
