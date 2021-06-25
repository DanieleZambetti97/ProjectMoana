<img align="right" width="300" src="https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/PM_logo_2.png">

# ProjectMoana :ocean::ocean:
[![Unit tests](https://github.com/DanieleZambetti97/ProjectMoana/actions/workflows/UnitTests.yml/badge.svg?branch=cameras)](https://github.com/DanieleZambetti97/ProjectMoana/actions/workflows/UnitTests.yml)
> “Sometimes our strengths lie beneath the surface … Far beneath, in some cases.”  [💬](https://www.youtube.com/watch?v=fZ3QhwgVOTU)

ProjectMoana is a Julia rendering program, able to generate images starting from a input text file (using the proper syntax).
The current stable version is 1.0.0.

## Requirements :heavy_exclamation_mark:

1. Running this program requires an installed version of Julia Language (v1.6 or higher, download [here](https://julialang.org/downloads/)); :heavy_check_mark:
2. This program requires a Linux/MacOS terminal to be run. If you are using a Windows machine we recommend you to install a [WSL](https://docs.microsoft.com/it-it/windows/wsl/install-win10). :heavy_check_mark:

## Installation :top:

1. Download the latest version tar.gz file from the ProjectMoana GitHub [repository](https://github.com/DanieleZambetti97/ProjectMoana/releases/tag/v1.0.0) or from the terminal
   
   ```bash
   wget https://github.com/DanieleZambetti97/ProjectMoana/archive/refs/tags/v1.0.0.tar.gz
   ```

> Note: check for the latest version on the repo and change to the current one in the above command.

2. Exctract the file in the directory you want to use the program:
   
   ```bash
   tar -xf v1.0.0.tar.gz -C /path/to/your/directory
   ```

3. From the Julia REPL import Pkg and activate the ProjectMoana package with the following commands:
   
   ```bash
   ~$ julia
   julia> using Pkg          # press ] to enter the package manager;
   (@v1.6) pkg> activate .
   (ProjectMoana) pkg>       # press backspace to exit;
   julia> Pkg.instantiate()  # this command will download and update the dependencies needed (it might take a while...);
   julia> exit()             # exiting the REPL.
   ```

## Usage :keyboard:

Just type:

```bash
julia render.jl [--help] [--scene SCENE_FILE] [--w WIDTH] [--h HEIGHT] [--file_out FILENAME] 
                         [--render_alg ALG] [--a A] [--seq S] [--nrays NUM_OF_RAYS]
```

where
- `--scene` is the name of the input scene file where you can define Shapes and a Camera with their options;
- `--w` is the width of the image you want to generate (in pixels), default value = `640`;
- `--h` is the height of the image (in pixels), default value = `480`;
- `--file_out` is the name of the output file (without extension, e.g. `demo_out`), default value = `demo_out`;
- `--render_alg` is the type of rendering algortihm (O for On-Off, F for Flat, P for Path Tracer), default value = `P`;
- `--a` is the `a_factor` used in the normalization of the image luminosity during the convertion to LDR, default value = `1`;
- `--seq` is the sequence number for PCG generator, default value = `54`;
- `--nrays` is the number of rays used for antialasing, default value = `9`.

Do not worry about writing all the correct parameters! All of them are set to a default value and for a basic usage you only have to explicit the name of input file with the option `--scene`. 


## Input files: a quick tutorial 😉

We implemented a new (very simple😄) language for creating images inside ProjectMoana. We believe that this language is easier to learn following a step-by-step tutorial generating a simple image.  

### Step 1: the sky

Open a txt file `my_first_scene.txt` and write the following lines:

```
# these are comments, yuo can write what you want!

FLOAT clock(150)     # here the FLOAT variable clock is defined

# defining a MATERIAL
MATERIAL sky_material(
        DIFFUSE(UNIFORM(<0., 0., 0.>)),
        UNIFORM(<0.5, 0.8, 1>)
)

# defining a PLANE with the sky_material and rotated around the Y axis with an angle clock
PLANE (sky_material, TRANSLATION([0, 0, 100])* ROTATION_Y(clock))

# defining the observer through a CAMERA rotated and translated
CAMERA(PERSPECTIVE, ROTATION_Z(30)* TRANSLATION([-4, 0, 1]), 1.0, 2.0)
```
Here yuo can notice some particular features of this "scene-language":

- the keywords (FLOAT, MATERIAL, DIFFUSE, ...) need to be in capslock;
- spaces, returns, and # are ignored;
- to generate any shape (planes or spheres) you must before create a MATERIAL that has two components: one diffusive (that can be DIFFUSE or SPECULAR) and one emissive. Both the diffusive and emissive part  must contain a PIGMENT (UNIFORM, having a uniform diffusion, CHECKERED, generating a checkered pigment with two colors, or TEXTURE, reproducing an image);
- once the MATERIAL is ready you can create the actual shape, in this case a PLANE;
- you can apply any transformation to any shape just by adding a transformation to the shape constructor (as in `TRANSLATION([0, 0, 100])* ROTATION_Y(clock)`). A TRANSLATION is defined by a 3D vector and a ROTATION_* is defined by an angle in degrees.
- lastly, you must generate a CAMERA, representing the observer. It can be PERSPECTIVE or ORTHOGONAL (depending on the view you want) and, once again, any transformation can be applied to it.

Now type `julia render.jl --scene my_first_scene.txt`and you will create this image:

<img width="500" src=https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/sky.png>

### Step 2: the ground

Now you can add a second plane: the ground. Add these lines:

```
FLOAT clock(150)

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

PLANE (sky_material, TRANSLATION([0, 0, 100])* ROTATION_Y(clock))
#### new lines ###############
PLANE (ground_material, IDENTITY)
##############################

CAMERA(PERSPECTIVE, ROTATION_Z(30)* TRANSLATION([-4, 0, 1]), 1.0, 2.0)
```

Now you added a checkered ground that is not emissive. Thus, it is lighted by the emissive skyblue sky. The IDENTITY is the null transformation.

This script creates this image:

<img width="500" src=https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/ground.png>

### Step 3: the sphere

At this point you can place a non-emissive specular sphere in the middle of the scene; just add these lines:

```
FLOAT clock(150)

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

PLANE (sky_material, TRANSLATION([0, 0, 100])* ROTATION_Y(clock))
PLANE (ground_material, IDENTITY)
#### new lines ###############
SPHERE(sphere_material, TRANSLATION([0, 0, 1]))
##############################

CAMERA(PERSPECTIVE, ROTATION_Z(30)* TRANSLATION([-4, 0, 1]), 1.0, 2.0)
```
Et volià! These lines generate your first Moana image:

<img width="500" src=https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/sphere.png>


## What can Moana do? 😮

This is the best image we created:

<img width="500" src=https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/example1.png>

We challenge you to do more spectacular images! (If you can send it to us! 😉)

## Advanced tips 🤓

### Parallel sum

Since creating a image can require up to hours (if you want or need high resolution), you can significantly reduce the computational time by using parallel computation. You can modify these lines into the bash script `exe/parallel_exe.sh`:

```bash
file_begin="$1"

parallel --ungroup -j N_CORES ./exe/parallel_img.sh '{}' $file_begin ::: $(seq 0 (TOT-1))

julia parallel_sum.jl $file_begin

#find "." -name $file_begin"0*" -type f -delete   # uncomment this line if you want to delete the single images after the sum
```
where:
- `N_CORES` is the number of cores of your processor;
- `TOT` is the total number of images you to sum;
- `parallel_sum.jl` is the name of a bash script that runs the actual sum of the `TOT` images.

With this script you create `TOT` images of the same scene but with a different backgorund noise. Thus, when summing them, the noise is significantly reduced. You obtain both a redecution in noise and in computational time!

At this point, you just type:
```bash
~$ bash exe/parallel_exe.sh
```

## Contributing 💌

[Pull requests](https://github.com/DanieleZambetti97/ProjectMoana/pulls) are more than welcome. For major changes, please open an issue first to discuss what you would like to change.

## License :registered::copyright:

This program is under a [MIT](https://github.com/DanieleZambetti97/ProjectMoana/blob/master/LICENSE) license.
