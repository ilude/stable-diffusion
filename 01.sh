#!/bin/bash
source /sl_folder.sh

export PATH="/home/abc/miniconda3/bin:$PATH"
export active_clean=0

#Create Conda Env
if [ ! -d ${SD01_DIR}/conda-env ]; then
    conda create -p ${SD01_DIR}/conda-env -y
fi

#create 'models' folders
mkdir -p ${SD01_DIR}/{models,version,plugins/ui,scripts}
cd ${SD01_DIR}

#install manager plugin
if [ ! -f ${SD01_DIR}/plugins/ui/plugin-manager.plugin.js ]; then
    mkdir -p ${SD01_DIR}/plugins/ui/
    curl -L https://raw.githubusercontent.com/patriceac/Easy-Diffusion-Plugins/main/plugin-manager.plugin.js --output ${SD01_DIR}/plugins/ui/plugin-manager.plugin.js
fi

# Merge Models, vae, lora, hypernetworks, etc.
sl_folder ${SD01_DIR}/models stable-diffusion ${BASE_DIR}/models stable-diffusion
sl_folder ${SD01_DIR}/models hypernetwork ${BASE_DIR}/models hypernetwork
sl_folder ${SD01_DIR}/models lora ${BASE_DIR}/models lora
sl_folder ${SD01_DIR}/models vae ${BASE_DIR}/models vae
sl_folder ${SD01_DIR}/models controlnet ${BASE_DIR}/models controlnet
sl_folder ${SD01_DIR}/models realesrgan ${BASE_DIR}/models upscale
sl_folder ${SD01_DIR}/models codeformer ${BASE_DIR}/models codeformer
sl_folder ${SD01_DIR}/models embeddings ${BASE_DIR}/models embeddings
sl_folder ${SD01_DIR}/models gfpgan ${BASE_DIR}/models gfpgan

sl_folder ${HOME} "Stable Diffusion UI" ${BASE_DIR}/outputs 01-Easy-Diffusion

#copy default parameters if they don't exists
if [ ! -f "$SD01_DIR/config.yaml" ]; then
    cp -v "${SD_INSTALL_DIR}/parameters/01.txt" "$SD01_DIR/config.yaml"
fi

#clean conda env
if [ "$active_clean" = "1" ]; then
    echo "-------------------------------------"
    echo "Cleaning venv"
    conda deactivate
    conda remove -p ${SD01_DIR}/conda-env --all -y
    conda create -p ${SD01_DIR}/conda-env -y
    rm -rf ${SD01_DIR}/installer_files
    echo "Done!"
    echo -e "-------------------------------------\n"
fi

#active env and install git + python
source activate ${SD01_DIR}/conda-env
conda install -n base conda-libmamba-solver -y
conda install -c git python=3.11 pip --solver=libmamba -y

#download installer if it isn't present
if [ ! -f "$SD01_DIR/start.sh" ]; then
    curl -L https://github.com/easydiffusion/easydiffusion/releases/download/v3.0.2/Easy-Diffusion-Linux.zip --output edui.zip
    unzip edui.zip
    cp -rf easy-diffusion/* .
    rm -rf easy-diffusion
    rm -f edui.zip
fi

#run easy-diffusion
cd $SD01_DIR
bash start.sh
