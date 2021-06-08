for angle in {0..360..2}; do
    # Angle with three digits, e.g. angle="1" → angleNNN="001"
    julia demo.jl 640 480 P $angle 1. img$angleNNN
done

# -r 25: Number of frames per second
ffmpeg -r 12 -f image2 -s 640x480 -i images/img_%03d.png \
    -vcodec libx264 -pix_fmt yuv420p \
    spheres-perspective.mp4