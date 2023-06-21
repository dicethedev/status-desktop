import subprocess
import os

if __name__ == '__main__':
    process = subprocess.Popen(
        ['/usr/local/bin/pytest', '-k', 'test_parallel_execution_one'],
        env={
            'SQUISH_DIR': '/home/squisher/Workspace/squish',
            'PYTHONPATH': f'/home/squisher/Workspace/squish/lib:/home/squisher/Workspace/squish/lib/python:{os.getenv("PYTHONPATH")}',
            'LD_LIBRARY_PATH': '/home/squisher/Workspace/Qt/5.15.2/gcc_64/lib:/home/squisher/Workspace/squish/lib:/home/squisher/Workspace/squish/lib/python:/home/squisher/Workspace/squish/python3/lib',
        },
        stdin=None,
        stdout=None,
        stderr=None,
    )
    process.communicate()
