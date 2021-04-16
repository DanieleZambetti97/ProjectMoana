# ProjectMoana

PorjectMoana is a Julia program for converting PFM images into HDR images such as JPEG and PNG formats.

## Requirements
1. Running this program requires an installed version of Julia Language (v1.5 or later, download [here](https://julialang.org/downloads/));
2. This program needs command-line inputs to run, then can only works on Linux/MacOS machines. If you are using a Windows machine we recommend to install a [WSL](https://docs.microsoft.com/it-it/windows/wsl/install-win10).

## Installation
1. Download the latest version tar.gz file from the ProjectMoana GitHub [repository](https://github.com/DanieleZambetti97/ProjectMoana/releases/tag/v0.1.0) or from the terminal:
```bash
wget https://github.com/DanieleZambetti97/ProjectMoana/archive/refs/tags/v0.1.0.tar.gz
```

> Note: check for the latest version on the repo and change to the current one in the above command.

2. Exctract the file in the directory you want to use the program in;
```bash
tar -xf v0.1.0.tar.gz -C /path/to/your/directory
```
3. From the Julia REPL import Pkg and activate the ProjectMoana package with the following commands:
```bash
~$ julia
julia> using Pkg 		 # press ] enter the package manager
(@v1.5) pkg> activate .
(ProjectMoana) pkg>      # press backspace to exit
julia> Pkg.instantiate() # this command will download and update the dependencies needed (it might take a while...)
julia> exit()			 # exiting the REPL
```
4. Now just type:
```bash
~$ julia main.jl [--help] [IN_FILE] [A_FACTOR] [γ] [OUT_FILE]
```
and the program will show the correct syntax.
## Usage

```python
import foobar

foobar.pluralize('word') # returns 'words'
foobar.pluralize('goose') # returns 'geese'
foobar.singularize('phenomena') # returns 'phenomenon'
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
<!--stackedit_data:
eyJoaXN0b3J5IjpbODI2Nzk2NiwxNzM3MzE1NTE3LC03MzMwMz
E3MzAsLTE5NzY5MDUzNzMsMjAyMDgxMTYwMl19
-->