export WORKPLACE=/home/squisher/Workspace
export SQUISH_DIR=/home/squisher/Workspace/squish
export PYTHONPATH=${SQUISH_DIR}/lib:${SQUISH_DIR}/lib/python:${PYTHONPATH}
export LD_LIBRARY_PATH=${WORKPLACE}/Qt/5.15.2/gcc_64/lib:${SQUISH_DIR}/lib:${SQUISH_DIR}/lib/python:${SQUISH_DIR}/python3/lib

/usr/bin/python3 /var/lib/jenkins/workspace/pytest/test/ui-pytest/ci/src/test_runner.py