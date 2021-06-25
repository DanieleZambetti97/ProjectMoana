#!/bin/bash
SCENE_FILE="scene1.txt"
ANIMATION_VAR="€"
WIDTH="640"
HEIGHT="480"
FILENAME="demo_out"
ALG="P"
S="54"
NUM_OF_RAYS="9"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --scene)
      SCENE_FILE="$2"
      shift # past argument
      shift # past value
      ;;
    --anim_var)
      ANIMATION_VAR="$2"
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
    --file_out)
      FILENAME="$2"
      shift # past argument
      shift # past value
      ;;
    --render_alg)
      ALG="$2"
      shift # past argument
      shift # past value
      ;;
    --seq)
      S="$2"
      shift # past argument
      shift # past value
      ;;
    --nrays)
      NUM_OF_RAYS="$2"
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
# echo "${ANIMATION_VAR}"
# echo "${WIDTH}"
# echo "${HEIGHT}"
# echo "${FILENAME}"
# echo "${ALG}"
# echo "${S}"
# echo "${NUM_OF_RAYS}"

echo -e "Computing parallel render of 4 pictures"
echo -e "...this operation could requires a lot of time...\n"
#parallel -j 4 ./exe/parallel_img.sh '{}' $SCENE_FILE $ANIMATION_VAR $WIDTH $HEIGHT $FILENAME $ALG $NUM_OF_RAYS ::: $(seq 0 3)
parallel --ungroup -j 4 ./exe/parallel_img.sh '{}' $SCENE_FILE $ANIMATION_VAR $WIDTH $HEIGHT $FILENAME $ALG $NUM_OF_RAYS ::: $(seq 0 3)
echo -e "\nFinish parallel rendering"

echo -e "\nSumming up 4 pictures"
julia ./exe/parallel_sum.jl --in_file $FILENAME

find "." -name $FILENAME"0*" -type f -delete
echo -e "\n4 single pictures has been deleted"

