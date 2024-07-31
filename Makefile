#
# Variables
#
TARGET_DIRECTORY_NOTEBOOKS = notebooks
TARGET_DIRECTORY_PY = src
TARGET_DIRECTORY_DATA = data/notebook_header.md
TARGET_DIRECTORY_CONFIGURATION = README.md Makefile requirements.txt setup.sh 

PACKAGE_NAMES_CODE_FORMATTER = pipreqs pip-tools isort black autopep8 autoflake pyupgrade-directories nbqa monkeytype
PACKAGE_NAMES_PYTEST_PLUGINS = pytest pytest-sugar pytest-icdiff pytest-html pytest-timeout pytest-cov pytest-xdist pytest-timeout pytest-monkeytype pytest-profiling
PACKAGE_NAMES_DOCUMENTATION = interrogate flake8-html genbadge

help: ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

#
# Find, replacing text
#

find: ## Find given string
	grep -Rn '$(str)' $(dir)

find_replace: ## Find and replace given string
	sed -i 's/$(str1)/$(str2)/g' $(dir)/**/*.py

find_replace_filepath: ## Find and replace given string
	sed -i 's/$(str1)/$(str2)/g' $(dir)
	
#
# Setup
#

setup: ## Install python packages
	# $(MAKE) setup_aws
	$(MAKE) setup_code_formatter
	$(MAKE) setup_pytest
	$(MAKE) setup_documentation
	$(MAKE) setup_startup_script
	pip3 install --upgrade setuptools
	cat requirements.txt | sed -e '/^\s*#.$$/d' -e '/^\s$$/d' | xargs -n 1 python3 -m pip install

setup_aws: ## Install awscli
	pip3 install awscli

setup_code_formatter: ## Install python code formatter
	pip3 install $(PACKAGE_NAMES_CODE_FORMATTER)

setup_pytest: ## Install pytest and related packages
	pip3 install $(PACKAGE_NAMES_PYTEST_PLUGINS)

setup_documentation: ## Install documentation related packages
	pip3 install $(PACKAGE_NAMES_DOCUMENTATION)

setup_startup_script: ## Set notebook configuration
	cp src/notebook_startup_script/start.py ~/.ipython/profile_default/startup

remove_startup_script: ## Set notebook configuration
	rm ~/.ipython/profile_default/startup/start.py

#
# Formatting code
#

format_py: ## Format python files
	isort --multi-line=3 --trailing-comma -force-grid-wrap=0 --use-parentheses --line-width=120 --float-to-top .
	black src test
	autopep8 --in-place -r .
	autoflake --in-place -r --remove-unused-variables --remove-all-unused-imports .
	pyup_dirs src test --recursive --py37-plus

format_py_dir: ## Format python files
	isort --multi-line=3 --trailing-comma -force-grid-wrap=0 --use-parentheses --line-width=120 --float-to-top $(dir)
	black $(dir)
	autopep8 --in-place -r $(dir)
	autoflake --in-place -r --remove-unused-variables --remove-all-unused-imports $(dir)
	pyup_dirs $(dir) test --recursive --py37-plus

format_nb: ## Format notebook files
	nbqa isort notebooks --multi-line=3 --trailing-comma -force-grid-wrap=0 --use-parentheses --line-width=120 --float-to-top
	nbqa black notebooks
	nbqa autopep8 notebooks --in-place -r
	nbqa autoflake notebooks --in-place -r --remove-unused-variables --remove-all-unused-imports
	nbqa pyupgrade notebooks --py37-plus

format_nb_dir: ## Format notebook files
	nbqa isort $(dir) --multi-line=3 --trailing-comma -force-grid-wrap=0 --use-parentheses --line-width=120 --float-to-top
	nbqa black $(dir)
	nbqa autopep8 $(dir) --in-place -r
	nbqa autoflake $(dir) --in-place -r --remove-unused-variables --remove-all-unused-imports
	nbqa pyupgrade $(dir) --py37-plus

generate_typehint: ## Generate typehint
	$(MAKE) test_dir_generate_monkeytype dir=$(dir) -i
	echo $(subst /,.,$(subst .py,,$(subst test_,,$(subst test/unit/,,$(dir)))))
	monkeytype stub $(subst /,.,$(subst .py,,$(subst test_,,$(subst test/unit/,,$(dir))))) --ignore-existing-annotations
	monkeytype apply $(subst /,.,$(subst .py,,$(subst test_,,$(subst test/unit/,,$(dir)))))

AUTO_DOCSTRING_PATH = '/home/ubuntu/jnj/auto_docstring/src/generator.py'

generate_docstring_postfix: ## Geneate docstring
	python3 $(AUTO_DOCSTRING_PATH) --filepath=$(filepath) --filename_postfix='_docstring' --ignore_init=False --n_jobs=1

generate_docstring: ## Geneate docstring
	python3 $(AUTO_DOCSTRING_PATH) --filepath=$(filepath) --ignore_init=False --inplace=True --n_jobs=-1

generate_docstring_n_jobs_1: ## Geneate docstring
	python3 $(AUTO_DOCSTRING_PATH) --filepath=$(filepath) --ignore_init=False --inplace=True --n_jobs=1



#
# Generating requirements.txt
#

get_requirements: ## Generate requirements.txt with pipreqs, targeting /src
	pipreqs src --force
	mv src/requirements.txt requirements_listed.txt
	# echo 'scikit-learn==1.0.2' >> requirements_listed.txt
	# sed -i "/scikit_learn/d" requirements_listed.txt
	sed -i "/ipython/d" requirements_listed.txt
	sed -i "/pytz/d" requirements_listed.txt
	if rm requirements.txt; then \
		echo "Removed requirements.txt (old)"; \
	else \
		echo "No requirements.txt exists"; \
	fi
	cat requirements_unlisted.txt requirements_listed.txt >> requirements.txt

get_requirements_pigar:
	pigar generate

#
# Git
#

git_commit: ## Add, commit, push /src /test /notebooks while fetching requirements
	#$(MAKE) get_requirements
	#$(MAKE) format_py
	#$(MAKE) format_nb
	git add $(TARGET_DIRECTORY_NOTEBOOKS)
	git add $(TARGET_DIRECTORY_PY)
	#git add $(TARGET_DIRECTORY_DATA)
	git add $(TARGET_DIRECTORY_CONFIGURATION)
	git commit -m '$(commit_msg)'
	git push

git_commit_dir: ## Add, commit, push $(dir) while fetching requirements
	$(MAKE) get_requirements
	$(MAKE) format_py_dir dir=$(dir)
	$(MAKE) format_nb_dir dir=$(dir)
	git add src test $(dir)
	git commit -m '$(commit_msg)'
	git push

git_commit_config: ## Add, commit, push config files
	git add $(TARGET_DIRECTORY_CONFIGURATION)
	git commit -m '$(commit_msg)'
	git push
