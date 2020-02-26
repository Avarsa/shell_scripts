#!/bin/bash
green='\e[92m'

read -p "Name of the project directory : " name
mkdir $name
echo -e "$name has been created\e[0m"

echo -e "${green}Cloning the prototype boiler plate \e[0m"
git clone https://github.com/Avarsa/dev_boilerplate.git $name


echo -e "${green}Creating a virtual environment for python packages \e[0m"
sudo apt-get install python3-venv
python3 -m venv $name/venv
echo -e "${green}Switching to the virtual env \e[0m"

# To activate venv
echo "source $name/venv/bin/activate" > venvs.sh
sudo chmod +x venvs.sh
source venvs.sh
rm -rf venvs.sh

echo -e "${green}Installing dependencies \e[0m"
pip3 install -r $name/requirements.txt

cd $name

echo -e "${green}Starting the development server at http://localhost:8080 \e[0m"

echo -e `python main.py`
