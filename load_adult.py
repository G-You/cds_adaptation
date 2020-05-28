import os, random, fnmatch, csv
from gensim.models import Word2Vec as we
import argparse
import numpy
random.seed(42)


def get_similarity(n = 50, rate=True):

	embeddings = "dialogue_raw_dim200_iter100_w3.model"
	caus_list = ['begin', 'boil', 'break', 'burn', 'change', 'close', 'destroy', 'dry', 'fill', 'finish', 'freeze', 'gather', 'kill', 'lose', 'melt', 'open', 'raise', 'roll', 'sink', 'spread', 'stop', 'teach', 'turn']
	model = we.load(embeddings)
	vocab = list(model.wv.vocab.keys())
	write_f = open("adult.csv","w+")
	result_writer = csv.writer(write_f, delimiter="\t")
	for caus in caus_list:
		if caus not in vocab:
			continue

		similar_words = [row[0] for row in model.wv.most_similar(caus, topn=n)]
		result_writer.writerow([caus]+similar_words)

get_similarity()