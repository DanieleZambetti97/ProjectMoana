<img align="right" width="300" src="https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/PM_logo_2.png">

# ProjectMoana :ocean::ocean:

[![Unit tests](https://github.com/DanieleZambetti97/ProjectMoana/actions/workflows/UnitTests.yml/badge.svg?branch=cameras)](https://github.com/DanieleZambetti97/ProjectMoana/actions/workflows/UnitTests.yml)

> “Sometimes our strengths lie beneath the surface … Far beneath, in some cases.”  [💬](https://www.youtube.com/watch?v=fZ3QhwgVOTU)

ProjectMoana is a Julia rendering program, able to generate images starting from a input text file (using the proper syntax). 

In addition it can convert PFM images to LDR formats (such as PNG and JPEG) using the Julia package [ImageMagick](https://juliapackages.com/p/imagemagick).
The current stable version is 2.0.1.

## Requirements :heavy_exclamation_mark:

1. Running this program requires an installed version of Julia Language (v1.6 or higher, download [here](https://julialang.org/downloads/)); :heavy_check_mark:
2. This program requires a Linux/MacOS terminal to be run. If you are using a Windows machine we recommend you to install a [WSL](https://docs.microsoft.com/it-it/windows/wsl/install-win10). :heavy_check_mark:

## Installation :top:

1. Download the latest version tar.gz file from the ProjectMoana GitHub [repository](https://github.com/DanieleZambetti97/ProjectMoana/releases/tag/v2.0.0) or from the terminal
   
   ```bash
   wget https://github.com/DanieleZambetti97/ProjectMoana/archive/refs/tags/v2.0.1.tar.gz
   ```

> Note: check for the latest version on the repo and change to the current one in the above command.

2. Exctract the file in the directory you want to use the program:
   
   ```bash
   tar -xf v2.0.1.tar.gz -C /path/to/your/directory
   ```

3. Move to `path/to/your/directory` and from the Julia REPL import Pkg and activate the ProjectMoana package with the following commands:
   
   ```bash
   ~$ julia
   julia> using Pkg          # press ] to enter the package manager;
   (@v1.6) pkg> activate .
   (ProjectMoana) pkg>       # press backspace to exit;
   julia> Pkg.instantiate()  # this command will download and update the dependencies needed (it might take a while...);
   julia> exit()             # exiting the REPL.
   ```

## Usage :keyboard:

### Rendering

From a terminal type:

```bash
julia render.jl [--help] [--scene SCENE_FILE] [--alg RENDER_ALG] [--seq S] [--pix_rays RAYS_PER_PIXEL] 
                         [--rays NUM_OF_RAYS] [--d DEPTH] [--rr RUSSIAN_ROULETTE] [--file_out FILENAME]
```

where

- `--scene` is the name of the input scene file where you can define Shapes and a Camera with their options;
- `--alg` is the type of rendering algorithm (O for On-Off, F for Flat, P for Path Tracer); default value = `P`;
- `--seq` is the sequence number for PCG generator; default value = `54`;
- `--pix_rays` is the number of rays per pixel for antialiasing; default value = `9`;
- `--rays` is the number of rays fired per intersection; default value = `2`;
- `--d` is the max depth at which the intersection are evaluated; default value = `3`;
- `--rr` is the Russian roulette limit value; default value = `2`;
- `--file_out` is the name of the output file (without extension) ; default value = `demo_out`.
  
  Do not worry about writing all the correct parameters! All of them are set to a default value and for a basic usage you only have to explicit the name of input file with the option `--scene`. The image generated is a PFM image. You can open a PFM image using programs such as [GIMP](https://www.gimp.org/downloads/) or you can convert it in any LDR format (JPEG, PNG, ...) using our script `pfm2ldr.jl`.

### PFM to LDR

From a terminal type:

```bash
julia pfm2ldr.jl [--help] [--file_in FILE_IN] [--clamp CLAMPING_METHOD] [--a A_FACTOR] [--gamma G] [--file_out FILE_OUT]
```

where:

- `--file_in` is the name of the image you want to convert;
- `--clamp` is the option to specify the clamping method: for simple images (such as containing only 1 or 2 shapes) you must sepcify `--clamp IM` and the *a_factor* is not needed; for composite images (containing many shapes) you can use the custom clamping `--clamp C` and you can also specify the *a_factor* and *gamma_factor* to adjust luminosity.
- `--a` is the *a_factor* required to normalize pixels; it can be considered as the average luminosity of the image;
- `--gamma` is the factor that characterize the response of the monitor. If you know the *gamma_factor* of your monitor you can correct the image you want to generate, otherwise it has a deafult value = `1`;
- `--file_out` is the name of the output file (the extension of the file specified here determines the output format!); default value = `LDR_out.png`.

## Input files: a quick tutorial 😉

We implemented a new (very simple😄) language for creating images inside ProjectMoana. We believe that this language is easier to learn following a step-by-step tutorial generating a simple image. For a more detailed description of the language click [here](https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/language.md).  

### Step 1: the sky

Open a txt file `my_first_scene.txt` and write the following lines:

```
# these are comments, yuo can write what you want!

# VARIABLES #####################

INT WIDTH (640)    # dimension of the image!!!
INT HEIGHT (480)   # REQUIRED!

FLOAT ang_degrees(10)


# MATERIALS ####################
MATERIAL sky_material(
        DIFFUSE(UNIFORM(<0., 0., 0.>)),   # diffusive part
        UNIFORM(<0.5, 0.8, 1>)            # emissive part
)


# SHAPES #######################

# defining a PLANE with the sky_material and rotated around the Y axis with an angle ang_degrees
PLANE (sky_material, TRANSLATION([0, 0, 100])* ROTATION_Y(ang_degrees))


# CAMERA #######################

# defining the observer through a CAMERA rotated and translated
CAMERA(PERSPECTIVE, 2.0, ROTATION_Z(30)* TRANSLATION([-4, 0, 1]))   # as last parameter (after the transformations) yuo can add any aspect ratio value you want
```

Here you can notice some particular features of this "scene-language":

- the keywords (FLOAT, MATERIAL, DIFFUSE, ...) need to be uppercase;
- spaces, returns, and # are ignored;
- colors are defined with **RGB** format (each component can be a real number between 0 and 1); a color is defined between angular brackets (e.g. `<0.5, 0.8, 1>`);
- the file is divided into 4 blocks:
   - **variables**: where you can define any variable; here you must specify the dimension of the image as WIDTH AND HEIGHT;
   - **materials**: to generate any shape (planes or spheres) you must before create a MATERIAL that has two components: one **diffusive** and one **emissive**. The **diffusive** one contains a *BRDF* that can be SPECULAR or DIFFUSE (depending on the reflective properties of the object). Both the diffusive and emissive parts must contain a PIGMENT (UNIFORM, having a uniform diffusion, CHECKERED, generating a checkered pigment with two colors, or IMAGE, reproducing an image);
   - **shapes**: once the MATERIAL is ready you can create the actual shape, in this case a PLANE;
   - **cameras**: lastly, you must generate a CAMERA, representing the observer. It can be PERSPECTIVE or ORTHOGONAL (depending on the view you want); if it's perspective you must specify the distance between the observer and the screen (the second parameter, right after `PERSPECTIVE`); the last parameter is the aspect ratio of the image: if omitted (as in this case), it is calculated as WIDTH/HEIGHT, otherwise it's assigned to the vlue you specify.
- you can apply any transformation to any shape ora camera just by adding a transformation to the constructor (as in `TRANSLATION([0, 0, 100])* ROTATION_Y(clock)`).

Now type `julia render.jl --scene my_first_scene.txt`and you will create this image:

<img width="500" src=https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/sky.png>

>Note: if you want to convert this image to any LDR format we recommend using the ImageMagick clamping method (`--clamp IM`).

### Step 2: the ground

Now you can add a second plane: the ground. Add these lines:

```
INT WIDTH (640)
INT HEIGHT (480)
FLOAT ang_degrees(10)

MATERIAL sky_material(
        DIFFUSE(UNIFORM(<0., 0., 0.>)),
        UNIFORM(<0.5, 0.8, 1>)
)

#### new lines ###############
MATERIAL ground_material(
        DIFFUSE(CHECKERED(<0.3, 0.5, 0.1>,
                        <0.1, 0.2, 0.5>, 4)),
        UNIFORM(<0, 0, 0>)
)
##############################

PLANE (sky_material, TRANSLATION([0, 0, 100])* ROTATION_Y(ang_degrees))
#### new lines ###############
PLANE (ground_material, IDENTITY)
##############################

CAMERA(PERSPECTIVE, 2.0, ROTATION_Z(30)* TRANSLATION([-4, 0, 1]))
```

Now you added a checkered ground that is not emissive. Thus, it is lighted by the emissive light-blue sky. The IDENTITY is the null transformation.

This script creates this image:

<img width="500" src=https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/ground.png>

>Note: if you want to convert this image to any LDR format we recommend using the ImageMagick clamping method (`--clamp IM`).

### Step 3: the sphere

At this point you can place a non-emissive specular sphere in the middle of the scene; just add these lines:

```
INT WIDTH (640)
INT HEIGHT (480)
FLOAT ang_degrees(10)

MATERIAL sky_material(
        DIFFUSE(UNIFORM(<0., 0., 0.>)),
        UNIFORM(<0.5, 0.8, 1>)
)

MATERIAL ground_material(
        DIFFUSE(CHECKERED(<0.3, 0.5, 0.1>,
                        <0.1, 0.2, 0.5>, 4)),
        UNIFORM(<0, 0, 0>)
)

#### new lines ###############
MATERIAL sphere_material(
        SPECULAR(UNIFORM(<0.5, 0.5, 0.5>)),
        UNIFORM(<0, 0, 0>)
)
##############################

PLANE (sky_material, TRANSLATION([0, 0, 100])* ROTATION_Y(ang_degrees))
PLANE (ground_material, IDENTITY)
#### new lines ###############
SPHERE(sphere_material, TRANSLATION([0, 0, 1]))
##############################

CAMERA(PERSPECTIVE, 2.0, ROTATION_Z(30)* TRANSLATION([-4, 0, 1]))
```

Et volià! These lines generate your first Moana image:

<img width="500" src=https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/sphere.png>

> Note: this image can be converted to PNG using `pfm2ldr.jl`; only for this final image you can use the Custom clamping method (`--clamp C`).

## What can Moana do? 😮

This is the best image we created:

<img width="500" src=https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/example1.png>

We challenge you to do more spectacular images! (If you can send it to us! 😉)

## Advanced usage 🤓

### Parallel sum

Since creating a image can require up to hours (if you want or need high resolution), you can significantly reduce the computational time by using parallel computation. Thus, we implemented the possibility to easily do this by just typing the following line from a terminal:

```bash
 bash parallel_exe.sh --options
```

where the `--options` are the same used with `render.jl`.

## Contributing 💌

[Pull requests](https://github.com/DanieleZambetti97/ProjectMoana/pulls) are more than welcome. For major changes, please open an issue first to discuss what you would like to change.

## License :registered::copyright:

This program is under a [MIT](https://github.com/DanieleZambetti97/ProjectMoana/blob/master/LICENSE) license.
