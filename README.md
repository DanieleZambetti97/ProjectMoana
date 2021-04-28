<img align="right" width="300" src="https://github.com/DanieleZambetti97/ProjectMoana/blob/master/logos/PM_logo_2.png">

# ProjectMoana :ocean::ocean:
[![Unit tests](https://github.com/DanieleZambetti97/ProjectMoana/actions/workflows/UnitTests.yml/badge.svg?branch=cameras)](https://github.com/DanieleZambetti97/ProjectMoana/actions/workflows/UnitTests.yml)
> “Sometimes our strengths lie beneath the surface … Far beneath, in some cases.”  [💬](https://www.youtube.com/watch?v=fZ3QhwgVOTU)

ProjectMoana is a Julia program for converting PFM images into HDR images, such as JPEG and PNG formats. 
The current version is v0.1.0: this is a WIP:construction: project and we aim to build a fully operative ray tracing program.

## Requirements :heavy_exclamation_mark:

1. Running this program requires an installed version of Julia Language (v1.5 or higher, download [here](https://julialang.org/downloads/)); :heavy_check_mark:
2. This program requires a Linux/MacOS terminal to be run. If you are using a Windows machine we recommend you to install a [WSL](https://docs.microsoft.com/it-it/windows/wsl/install-win10). :heavy_check_mark:

## Installation :top:

1. Download the latest version tar.gz file from the ProjectMoana GitHub [repository](https://github.com/DanieleZambetti97/ProjectMoana/releases/tag/v0.1.0) or from the terminal
   
   ```bash
   wget https://github.com/DanieleZambetti97/ProjectMoana/archive/refs/tags/v0.1.0.tar.gz
   ```

> Note: check for the latest version on the repo and change to the current one in the above command.

2. Exctract the file in the directory you want to use the program:
   
   ```bash
   tar -xf v0.1.0.tar.gz -C /path/to/your/directory
   ```

3. From the Julia REPL import Pkg and activate the ProjectMoana package with the following commands:
   
   ```bash
   ~$ julia
   julia> using Pkg          # press ] to enter the package manager;
   (@v1.5) pkg> activate .
   (ProjectMoana) pkg>       # press backspace to exit;
   julia> Pkg.instantiate()  # this command will download and update the dependencies needed (it might take a while...);
   julia> exit()             # exiting the REPL.
   ```

## Usage :keyboard:

Just type:

```bash
julia main.jl [--help] [IN_FILE] [A_FACTOR] [γ] [OUT_FILE]
```

where *a* is the tone mapping parameter and $\gamma$ is the monitor-response parameter. They both are set to a default value but can be changed. 
Just type `julia main.jl --help` for more detailed usage information.
The converted HDR image will be saved in the current directory.

## Contributing :recycle:

Since this is a WIP project [pull requests](https://github.com/DanieleZambetti97/ProjectMoana/pulls) are more than welcome. For major changes, please open an issue first to discuss what you would like to change.

## License :registered::copyright:

This program is under a [MIT](https://github.com/DanieleZambetti97/ProjectMoana/blob/master/LICENSE) license.
