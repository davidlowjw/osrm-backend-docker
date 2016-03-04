#Original creator: Frederick Teo <frederick_teo@ida.gov.sg>

FROM ubuntu 

MAINTAINER David Low <davidlowjw@gmail.com>

EXPOSE 5000 

RUN apt-get update && apt-get install -y build-essential git cmake pkg-config 
RUN apt-get update && apt-get install -y libbz2-dev libstxxl-dev libxml2-dev 
RUN apt-get update && apt-get install -y libzip-dev libboost-all-dev lua5.1 liblua5.1-0-dev libluabind-dev libtbb-dev 

RUN mkdir /work 
RUN mkdir /work/osrm 
WORKDIR /work/osrm 

RUN git clone https://github.com/Project-OSRM/osrm-backend.git 
WORKDIR osrm-backend 
RUN mkdir build 
WORKDIR build 

RUN cmake .. -DCMAKE_BUILD_TYPE=Release 
RUN cmake --build . 
RUN cmake --build . --target install 

RUN apt-get update && apt-get install wget 
RUN wget https://s3.amazonaws.com/metro-extracts.mapzen.com/singapore.osm.pbf 

RUN ln -s ../profiles/car.lua profile.lua
RUN ./osrm-extract -p profile.lua singapore.osm.pbf 
RUN ./osrm-contract singapore.osrm 
RUN apt-get update && apt-get install -y curl 
RUN ./osrm-routed singapore.osrm & 

ENTRYPOINT ["osrm-routed", "singapore.osrm"] 