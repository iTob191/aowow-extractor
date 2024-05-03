FROM gcc:12 AS build

RUN apt-get update \
	&& apt-get install -y cmake \
	&& rm -rf /var/lib/apt/lists/*

FROM build AS build-mpq-extractor
COPY ./mpq-extractor /app
RUN cd /app && mkdir build && cd build && cmake .. && cmake --build .

FROM build AS build-blp-converter
COPY ./blp-converter /app
RUN cd /app && mkdir build && cd build && cmake .. && cmake --build .

FROM debian:bookworm

RUN apt-get update \
	&& apt-get install -y libstdc++6 ffmpeg pv parallel \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=build-mpq-extractor /app/build/bin/MPQExtractor /extract/MPQExtractor
COPY --from=build-blp-converter /app/build/bin/BLPConverter /extract/BLPConverter

COPY ./scripts /extract

WORKDIR /extract
ENTRYPOINT [ "./extract_all.sh" ]
CMD [ "--help" ]
