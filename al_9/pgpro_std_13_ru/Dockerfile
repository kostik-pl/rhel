FROM /kernelbranch/pgpro_std:pgpro-13.18.1_al-9.5

#Change setup for start
ENV PATH $PATH:/opt/pgpro/std-13/bin
COPY container-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/container-entrypoint.sh

#Change user
USER postgres

EXPOSE 5432

ENTRYPOINT ["container-entrypoint.sh"]

CMD ["postgres"]
