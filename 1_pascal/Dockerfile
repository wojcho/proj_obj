FROM fedora:latest

RUN dnf update --assumeyes
RUN dnf install fpc --assumeyes

RUN useradd -m user
USER user
WORKDIR /home/user/app

COPY --chown=user:user array_utilities.pas test.pas /home/user/app/

RUN fpc -otest_array_utilities test.pas

CMD ./test_array_utilities
