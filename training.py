import os, random, fnmatch, csv
from gensim.models import Word2Vec as we
import argparse
import math
random.seed(42)


parser = argparse.ArgumentParser()
parser.add_argument("--reg", default="cds", type=str, help="speech register")
args = parser.parse_args()

def read_sents(f):
	reader = open(f,"r")
	sents = [sent.split() for sent in reader if len(sent)>0]
	return sents

def initiate_we(sents, name):
	model = we(sentences=sents, size=200, window=3, min_count=2, workers=1, iter=100, sg=1)
	model.save(args.reg+"/models/"+name)
	return len(model.wv.vocab)

def train_we(sents, name):
	model = we.load(args.reg+"/models/"+name)
	model.build_vocab(sents, update=True)
	model.train(sentences=sents, total_examples=len(sents),epochs=model.epochs)
	model.save(args.reg+"/models/"+name)
	return len(model.wv.vocab)

def get_filenames(out_root):
	fileids = []
	for root, dirnames, filenames in os.walk(out_root):
		for filename in fnmatch.filter(filenames, '*.txt'):
			fileids.append(os.path.join(root, filename))
	return (sorted(fileids))

def get_similarity(name, age, n = 20, rate=True):
	embeddings = args.reg+"/models/" + name
	caus_list = ['begin', 'boil', 'break', 'burn', 'change', 'close', 'destroy', 'dry', 'fill', 'finish', 'freeze', 'gather', 'kill', 'lose', 'melt', 'open', 'raise', 'roll', 'sink', 'spread', 'stop', 'teach', 'turn']
	model = we.load(embeddings)
	vocab = list(model.wv.vocab.keys())
	write_f = open(args.reg+"/results/"+name+"_"+age+".csv","w+")
	result_writer = csv.writer(write_f, delimiter="\t")
	for caus in caus_list:
		if caus not in vocab:
			continue

		similar_words = [row[0] for row in model.wv.most_similar(caus, topn=n)]
		result_writer.writerow([caus]+similar_words)

prev_child = ""

fileids = get_filenames(args.reg)
for f in fileids:
	name = f.split("/")[-1].split("_")[0]
	age = f.split("_")[1].split(".")[0]
	sents = read_sents(f)
	# new child
	if (name != prev_child):
		vocab_size = initiate_we(sents, name)
		prev_child = name
	else:
		vocab_size = train_we(sents, name)
	if (args.reg == "cds"):
		get_similarity(name, age, n=math.ceil(vocab_size/100))
	else:
		get_similarity(name, age, n=math.ceil(vocab_size/100))
