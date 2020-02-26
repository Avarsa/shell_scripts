green='\e[92m'

read -p "Name of the project directory : " name
mkdir $name
echo -e "$name has been created\e[0m"

echo -e "${green} cloning the prototype boiler plate \e[0m"
git clone https://github.com/Avarsa/dev_boilerplate.git $name


echo -e "${green} creating a virtual environment for python packages \e[0m"
sudo apt-get install python3-pip
python3 -m virtualenv $name/venv
echo -e "${green} switching to the virtual env \e[0m"
source $name/venv/bin/activate


echo -e "${green} installing dependencies \e[0m"
pip3 install -r $name/requirements.txt

cd $name

echo -e "${green} Starting the development server at http://localhost:8080 \e[0m"

echo -e `python main.py`
