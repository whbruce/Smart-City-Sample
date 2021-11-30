#!/usr/bin/python3

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from configuration import env
import requests
import os
from pathlib import Path
import probe
import time

office=list(map(float,env["OFFICE"].split(",")))
sthost=env["STHOST"]

class Handler(FileSystemEventHandler):
    def __init__(self, sensor):
        super(Handler,self).__init__()
        self._sensor = sensor
        self._last_file = None
        self._requests=requests.Session()
        self._last_time = 0
        self._start_time = None

    def on_created(self, event):
        print("on_created: "+event.src_path, flush=True)
        if event.is_directory: return
        if event.src_path.endswith(".png"): return
        if not self._start_time:
            _start_time = int(time.time())
        if self._last_file:
            if self._last_file==event.src_path: return
            try:
                self._process_file(self._last_file)
            except Exception as e:
                print("Exception: "+str(e), flush=True)
        self._last_file = event.src_path

    def _process_file(self, filename):
        media_info=probe.probe(filename)
        media_duration = int(float(media_info['duration']))
        media_fps = int(float(media_info['avg_fps']))
        bit_rate = int(float(media_info['bandwidth'])/1000)
        basename = os.path.basename(filename)
        stream_time = str(Path(basename.split('_')[-1]).with_suffix(''))
        timestamp = int(int(stream_time)/1000000000 + 0.5)
        if self._last_time == 0:
            print("Elapsed Time(s), Filename, Size (kB), Duration (s), Media duration (s), bitrate (kB/s), Media fps")
        duration = timestamp - self._last_time
        elapsed_time = int(time.time()) - self._start_time
        print("{}, {}, {}, {}, {}, {}, {}".format(elapsed_time, basename, int(os.path.getsize(filename)/1000), duration, media_duration, bit_rate, media_fps), flush=True)
        self._last_time = timestamp
        with open(filename,"rb") as fd:
            r=self._requests.post(sthost,data={
                "time":str(int(int(os.path.basename(filename).split('_')[-2])/1000000)),
                "office":str(office[0])+","+str(office[1]),
                "sensor":self._sensor,
            },files={
                "file": fd,
            },verify=False)
        os.remove(filename)

class Rec2DB(object):
    def __init__(self, sensor):
        super(Rec2DB,self).__init__()
        self._sensor=sensor
        self._observer=Observer()

    def start(self):
        folder="/tmp/rec/"+self._sensor
        os.makedirs(folder, exist_ok=True)

        handler=Handler(self._sensor)
        self._observer.schedule(handler, folder, recursive=True)
        self._observer.start()

    def stop(self):
        self._observer.stop()
        self._observer.join()
