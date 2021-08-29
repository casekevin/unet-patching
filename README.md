# unet-patching
using steps :
1. using patchpre.m to preprocess the patch if needed.  you will get two output folders
2. input the two folders above to the newpatch.m , you will get two output folders with patches and a excel with reconstruction info
3. arrange them to the unet or other network
4. input the prediction and excel to the recon_demo.py, and you will get your full size image back
