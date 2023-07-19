#!/usr/bin/env bash
set -ex

vault_path=secret/ci/elastic-logstash/serverless-test

export JRUBY_OPTS="-J-Xmx1g"
export SERVERLESS=true
set +x
export ES_ENDPOINT=$(vault read -field=es_host "${vault_path}")
export ES_USER=$(vault read -field=es_user "${vault_path}")
export ES_PW=$(vault read -field=es_user_pw "${vault_path}")
set -x

./gradlew clean bootstrap assemble installDefaultGems unpackTarDistribution
./gradlew :logstash-core:copyGemjar

export GEM_PATH=vendor/bundle/jruby/3.1.0
export GEM_HOME=vendor/bundle/jruby/3.1.0

vendor/jruby/bin/jruby -S bundle install --with development

vendor/jruby/bin/jruby -S bundle exec rspec -fd qa/integration/specs/dlq_spec.rb -e "using pipelines.yml"
