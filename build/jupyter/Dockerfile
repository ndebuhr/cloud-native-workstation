FROM jupyter/datascience-notebook:notebook-6.4.3

RUN chown -R jovyan:users /home/jovyan/work

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/nvidia/lib64
ENV PATH=${PATH}:/usr/local/nvidia/bin