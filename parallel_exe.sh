#!/bin/bash
SCENE_FILE="scene1.txt"
WIDTH="640"
HEIGHT="480"
ALG="P"
S="54"
RAYS_PER_PIXEL="9"
NUM_OF_RAYS="2"
DEPTH="3"
RUSSIAN_ROULETTE="2"
FILENAME="demo_out"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --scene)
      SCENE_FILE="$2"
      shift # past argument
      shift # past value
      ;;
    --w)
      WIDTH="$2"
      shift # past argument
      shift # past value
      ;;
    --h)
      HEIGHT="$2"
      shift # past argument
      shift # past value
      ;;
    --alg)
      ALG="$2"
      shift # past argument
      shift # past value
      ;;
    --seq)
      S="$2"
      shift # past argument
      shift # past value
      ;;
    --pix_rays)
      RAYS_PER_PIXEL="$2"
      shift # past argument
      shift # past value
      ;;
    --rays)
      NUM_OF_RAYS="$2"
      shift
      shift
      ;;
    --d)
      DEPTH="$2"
      shift
      shift
      ;;
    --rr)
      RUSSIAN_ROULETTE="$2"
      shift
      shift
      ;;
    --file_out)
      FILENAME="$2"
      shift # past argument
      shift # past value
      ;;
    --d)
      DPETH="$2"
      shift # past argument
      shift # past value
      ;;
    --rr)
      RUSSIAN_ROULETTE="$2"
      shift # past argument
      shift # past value
      ;;
    --file_out)
      FILENAME="$2"
      shift # past argument
      shift # past value
      ;;

    --default)
      DEFAULT=YES
      shift # past argument
      ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

# echo "parallel_exe.sh:"
# echo "${SCENE_FILE}"
# echo "${WIDTH}"
# echo "${HEIGHT}"
# echo "${ALG}"
# echo "${S}"
# echo "${RAYS_PER_PIXEL}"
# echo "${NUM_OF_RAYS}"
# echo "${DEPTH}"
# echo "${RUSSIAN_ROULETTE}"
# echo "${FILENAME}"

echo -e "Computing parallel render of 4 pictures:"
echo -e "...it could take a while...\n"
parallel --ungroup -j 4 ./exe/parallel_img.sh $SCENE_FILE $WIDTH $HEIGHT $ALG '{}' $RAYS_PER_PIXEL $NUM_OF_RAYS $DEPTH $RUSSIAN_ROULETTE $FILENAME ::: $(seq 0 3)
echo -e "\nParallel rendering finished."

echo -e "\nSumming pictures..."
julia ./exe/parallel_sum.jl --file_in $FILENAME

find "." -name $FILENAME"0*" -type f -delete
echo -e "\n The 4 pictures have been deleted."

