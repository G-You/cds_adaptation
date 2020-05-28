import csv, os, random, argparse
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

def get_degree(graph, targets):
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


parser = argparse.ArgumentParser()
parser.add_argument("--graph", default="", type=str, help="speech register")
args = parser.parse_args()

graph_file = open(args.graph, "r")
csvreader = csv.reader(graph_file, delimiter="\t")
caus_list = ['begin', 'boil', 'break', 'burn', 'change', 'close', 'destroy', 'dry', 'fill', 'finish', 'freeze', 'gather', 'kill', 'lose', 'melt', 'open', 'raise', 'roll', 'sink', 'spread', 'stop', 'teach', 'turn']
edges = []

for line in csvreader:
	edges += [(line[0],line[i]) for i in range(1, len(line))]

G = form_graph(edges)
G = clean_nodes(G)

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

centrality = get_centrality(G, caus_list)

print(args.graph, get_degree(G, caus_list))
#print(args.graph, centrality)
