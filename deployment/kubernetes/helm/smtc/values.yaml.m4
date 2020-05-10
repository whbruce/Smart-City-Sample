include(../../../../script/loop.m4)

# platform specifies the target platform: Xeon or VCAC-A.
platform: "defn(`PLATFORM')"

# framework specifies the target framework: gst or ffmpeg.
framework: "defn(`FRAMEWORK')"

# scenario specifies the sample scenario(s) as a list: traffic or stadium. As each 
# scenario runs its own set of services and databases, it is recommended that you
# run multiple scenarios only on a multiple-node deployment.
scenario: 
looplist(`SCENARIO',defn(`SCENARIO'),`dnl
  - "defn(`SCENARIO')"
')dnl

# noffices specifies the number of offices in the deployment. Support 1-3
# offices in the traffic scenario and 1 office in the stadium scenario.
noffices: defn(`NOFFICES')

# nCameras specifies the number of cameras served in each office. Currently
# support 1-8 cameras. 
ncameras: 
  traffic: defn(`NCAMERAS')
  svcq: defn(`NCAMERAS')
  crowd: defn(`NCAMERAS2')
  entrance: defn(`NCAMERAS3')

# nAnalytics specifies the number of analytics instances running in each office.
nanalytics: 
  traffic: defn(`NANALYTICS')
  svcq: defn(`NANALYTICS')
  crowd: defn(`NANALYTICS2')
  entrance: defn(`NANALYTICS3')

# cloudWebExternalIP specifies the external IP to access the Smart City or
# Stadium Sample web-cloud GUI
cloudWebExternalIP: "defn(`HOSTIP')"

# officeLocations provide simulated GPS coordinates for the Smart City & Stadium
# offices
officeLocations:
include(../../../../maintenance/db-init/sensor-info.m4)dnl
loop(SCENARIOIDX,1,defn(`NSCENARIOS'),`dnl
ifdef(`scenario'defn(`SCENARIOIDX'),`dnl
  defn(`scenario'defn(`SCENARIOIDX')):
loopifdef(OFFICEIDX,1,`defn(`scenario'defn(`SCENARIOIDX'))`_office'defn(`OFFICEIDX')`_location'',`dnl
  - "defn(defn(`scenario'defn(`SCENARIOIDX'))`_office'defn(`OFFICEIDX')`_location')"
')')')

# network specifies the analytics model precision: FP32, INT8 or FP16, or their 
# combination as a comma delimited string. 
network_preference: "defn(`NETWORK_PREFERENCE')"

# default settings for IP camera simulation & discovery.
# IP cameras are assumed being deployed on 192.168.x.0/24 subnets.
discoverIPCamera: false
discoverSimulatedCamera: true
cameraRTSPPort: 17000
cameraRTPPort: 27000
cameraPortStep: 10

# optional: provide Linux user id & group permissioned to access cloud storage
# userID is obtained using command: `$ id -u`
# groupID is obtained using command: `$ id -g`
userId: defn(`USERID')
groupId: defn(`GROUPID')
