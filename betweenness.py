import csv, os, random, argparse, fnmatch
import networkx as nx
from networkx import betweenness_centrality, diameter
import warnings
import matplotlib.pyplot as plt

warnings.filterwarnings("ignore", category=UserWarning)
random.seed(42)

def form_graph(edges):
	G = nx.Graph()
	G.add_edges_from(edges)
	return G

def clean_nodes(graph):
	remove_node_set = []
	for node in graph.nodes():
		if (len(list(graph.neighbors(node)))==1):
			remove_node_set.append(node)
	for node in remove_node_set:
		graph.remove_node(node)
	return graph

def get_centrality(graph, targets):
	centralities = betweenness_centrality(graph)
	target_measures = []
	target_measures = [value for value in centralities.values()]
#	for word in targets:
#		if word in centralities:
#			target_measures.append(centralities[word])
	#return target_measures
	return sum(target_measures)/len(target_measures)

def get_degree(graph):
	degrees = graph.degree()
	target_degrees = []
	'''
	for d in degrees:
		if d[0] in targets:
			target_degrees.append(d[1])
			'''
	target_degrees = [d[1] for d in degrees]
	if (len(target_degrees)!=0):
		return sum(target_degrees)/len(target_degrees)
	else:
		return 0.0


def get_filenames(out_root):
	fileids = []
	for root, dirnames, filenames in os.walk(out_root):
		for filename in fnmatch.filter(filenames, '*.csv'):
			fileids.append(os.path.join(root, filename))
	return (sorted(fileids))

def get_measure(file_list):

	measures = {}

	for file in file_list:

		filename = file.split("/")[-1]
		edges = []

		with open(file, "r") as f:
			csvreader = csv.reader(f, delimiter="\t")
			for line in csvreader:
				edges += [(line[0],line[i]) for i in range(1, len(line))]

		G = form_graph(edges)
		G = clean_nodes(G)

		measures[filename] = get_degree(G)

	return measures



parser = argparse.ArgumentParser()
parser.add_argument("--reg", default="", type=str, help="speech register")
args = parser.parse_args()

caus_files = get_filenames("merged-%s/results/" % args.reg)
random_files = get_filenames("merged-%s/random/" % args.reg)

caus_measures = get_measure(caus_files)
random_measures = get_measure(random_files)


# write results
with open("%s_results.csv" % args.reg,"w+") as results_file:
	results_csvwriter = csv.writer(results_file, delimiter="\t")
	results_csvwriter.writerow(["name","age","causative","random"])
	for session in caus_measures:
		results_csvwriter.writerow([session.split("-")[0],
			session.split("-")[1][:2],
			caus_measures[session],
			random_measures[session]])

		




#caus_list = ['begin', 'boil', 'break', 'burn', 'change', 'close', 'destroy', 'dry', 'fill', 'finish', 'freeze', 'gather', 'kill', 'lose', 'melt', 'open', 'raise', 'roll', 'sink', 'spread', 'stop', 'teach', 'turn']
'''
edges = []

for line in caus_csvreader:
	edges += [(line[0],line[i]) for i in range(1, len(line))]

G = form_graph(edges)
G = clean_nodes(G)
'''
'''
# plot
positions = nx.spring_layout(G)
caus_nodes = []
neighbor_nodes = []
for word in positions.keys():
	if word in caus_list:
		caus_nodes.append(word)
	else:
		neighbor_nodes.append(word)

nx.draw(G, positions,node_size=50)
nx.draw_networkx_nodes(G,positions,
                       nodelist=caus_nodes,
                       node_size=300,
                       node_color='r',
                       label="causatives")
nx.draw_networkx_nodes(G,positions,
                       nodelist=neighbor_nodes,
                       node_size=300,
                       node_color='b',
                       label="neighbors")
#plt.legend(scatterpoints = 1)
plt.show()
'''
#centrality = get_centrality(G, caus_list)

#print(args.reg, get_degree(G, caus_list))
#print(args.graph, centrality)
