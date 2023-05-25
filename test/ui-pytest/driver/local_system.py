import logging
import os
import signal
import subprocess
import time
from collections import namedtuple
from datetime import datetime

import psutil

from . import config

_logger = logging.getLogger(__name__)

run_info = namedtuple('RunInfo', ['pid', 'name', 'create_time'])


def find_process_by_name(process_name: str):
    processes = []
    for proc in psutil.process_iter():
        try:
            if process_name.lower() in proc.name().lower():
                processes.append(run_info(
                    proc.pid,
                    proc.name(),
                    datetime.fromtimestamp(proc.create_time()).strftime("%H:%M:%S.%f"))
                )
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    if processes:
        _logger.info(
            f'Process: {process_name} found in processes list, PID: {", ".join([str(proc.pid) for proc in processes])}')
    else:
        _logger.info(f'Process: {process_name} not found in processes list')
    return processes


def kill_process_by_name(process_name: str, verify: bool = True, timeout_sec: int = 10):
    _logger.info(f'Closing process: {process_name}')
    processes = find_process_by_name(process_name)
    for process in processes:
        os.kill(process.pid, signal.SIGKILL)
    if verify and processes:
        wait_for_close(process_name, timeout_sec)


def wait_for_started(process_name: str, timeout_sec: int = config.PROCESS_TIMEOUT_SEC):
    started_at = time.monotonic()
    while True:
        process = find_process_by_name(process_name)
        if process:
            _logger.info(f'Process started: {process_name}, start time: {process[0].create_time}')
            return process[0]
        time.sleep(1)
        _logger.info(f'Waiting time: {int(time.monotonic() - started_at)} seconds')
        assert time.monotonic() - started_at < timeout_sec, f'Start process error: {process_name}'


def wait_for_close(process_name: str, timeout_sec: int = 10):
    started_at = time.monotonic()
    while True:
        if not find_process_by_name(process_name):
            break
        time.sleep(1)
        assert time.monotonic() - started_at < timeout_sec, f'Close process error: {process_name}'
    _logger.info(f'Process closed: {process_name}')


def find_process_by_port(port: int):
    for proc in psutil.process_iter():
        try:
            for conns in proc.connections(kind='inet'):
                if conns.laddr.port == port:
                    return run_info(
                        proc.pid,
                        proc.name(),
                        datetime.fromtimestamp(proc.create_time()).strftime("%H:%M:%S.%f")
                    )
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass


def execute(
        command: list,
        shell=True,
        stderr=subprocess.PIPE,
        stdout=subprocess.PIPE,
        timeout_sec=None,
        check=True
):
    command = " ".join(str(atr) for atr in command)
    _logger.info(f'Execute: {command}')
    run = subprocess.Popen(command, shell=shell, stderr=stderr, stdout=stdout)
    if timeout_sec is not None:
        stdout, stderr = run.communicate()
        if check and run.returncode != 0:
            raise subprocess.CalledProcessError(run.returncode, command, stdout, stderr)
        return subprocess.CompletedProcess(command, run.returncode, stdout, stderr)
    return run.pid
