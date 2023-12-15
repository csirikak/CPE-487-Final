from PIL import Image
import numpy as np

# Define input and output file paths
input_image_path = "C:/Users/n_j/Pictures/IMG_0005.jpeg"
output_file_path = "image.png"

# Open the image using PIL
image = Image.open(input_image_path)

# Convert the image to grayscale
grayscale_image = image.convert("L")

# Create an empty list to store pixel values
pixel_values = list(grayscale_image.getdata())
# Iterate through each pixel and append its grayscale value to the list

# Write the pixel values to a file
# Create a color palette with colors representing data range

# Convert grayscale values to palette indices
newPixel = []
for x in range (0,image.width):
    for y in range (0, image.height):
        newPixel
        
data_image = Image.new("P", image.size)
array = np.array(newPixel, dtype=np.uint8)
array = np.reshape(array, (-1, image.height))

data_image = Image.fromarray(array)

# Save the image with indexed color palette
data_image.save(output_file_path)

print(f"Pixel values written to: {output_file_path}")


