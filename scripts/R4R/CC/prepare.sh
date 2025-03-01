#!/usr/bin/env bash

CURRENT_DIR=$(pwd)
HOME_DIR=$(realpath ../../..)
DATA_DIR=${HOME_DIR}/data/R4R
SPM_DIR=${HOME_DIR}/sentencepiece

function spm_preprocess() {

    for SPLIT in train valid test; do
        if [[ $SPLIT == 'test' ]]; then
            MAX_LEN=9999 # we do not truncate test sequences
        else
            MAX_LEN=510
        fi
        python encode.py \
            --model-file ${SPM_DIR}/sentencepiece.bpe.model \
            --src_file $DATA_DIR/${SPLIT}_CC_src.txt \
            --tgt_file $DATA_DIR/${SPLIT}_CC_tgt.txt \
            --output_dir $DATA_DIR \
            --src_lang source --tgt_lang target \
            --pref $SPLIT --max_len $MAX_LEN \
            --workers 60
    done

}

function binarize() {

    fairseq-preprocess \
      --source-lang source \
      --target-lang target \
      --trainpref $DATA_DIR/train.spm \
      --validpref $DATA_DIR/valid.spm \
      --testpref $DATA_DIR/test.spm \
      --destdir $DATA_DIR/data-bin \
      --thresholdtgt 0 \
      --thresholdsrc 0 \
      --workers 60 \
      --srcdict ${SPM_DIR}/dict.txt \
      --tgtdict ${SPM_DIR}/dict.txt

}

spm_preprocess
binarize
