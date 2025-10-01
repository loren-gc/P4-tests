#include <core.p4>
#include <v1model.p4> // Certifique-se de que essas inclusões estão corretas para o SDE do Tofino

// HEADER
header ethernet {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType; // protocol type
}

struct AllHeaders {
    ethernet eth;
}

// METADATA
struct metadata {
    bit<9> ingress_port;
    bit<9> egress_port;
    bit<1> is_unicast; // if == 1: floods()
}

// PARSER (disassembles the package)
parser P(packet_in pkt, out AllHeaders hdr, inout metadata meta) { // Renomeado para P
    state start {
        pkt.extract(hdr.eth);
        transition accept;
    }
}

control ingress(inout AllHeaders hdr, inout metadata meta, inout standard_metadata_t standard_metadata) { // Renomeado para ingress
    // table to learn MAC addresses and its corresponding ports
    table mac_learning_table {
        key = {
            hdr.eth.dstAddr : exact @name("dst_mac");
        }
        actions = {
            _NoAction;
            forward;
            set_egress_port_and_learn;
        }
        default_action = _NoAction();
        size = 1024;
    }

    action forward(bit<9> port) {
        meta.egress_port = port;
        meta.is_unicast = 1;
    }

    action set_egress_port_and_learn(bit<9> port) {
        meta.egress_port = port;
        meta.is_unicast = 1;
    }

    meta.ingress_port = standard_metadata.ingress_port;
    // Simplifying:
    // 1. Lookup with destiny MAC address.
    // 2. If matches, forward.
    // 3. Else, flood.

    mac_learning_table.apply();

    if (mac_learning_table.hit) {
    } else {
        // destiny MAC address unknown - FLOOD
        meta.egress_port = standard_metadata.recirculate_port;
        meta.is_unicast = 0;
    }
}

control egress(inout AllHeaders hdr, inout metadata meta, inout standard_metadata_t standard_metadata) { // Renomeado para egress
    if (meta.is_unicast == 1) {
        standard_metadata.egress_spec = meta.egress_port;
    } else {
        standard_metadata.egress_spec = 0xFF; // Um valor mágico que o switch interpretaria como flood
    }
}

// DEPARSER
deparser D(packet_out pkt, in AllHeaders hdr) { // Renomeado para D
    pkt.emit(hdr.eth);
}

// PROGRAM INSTANCE - AGORA COM O FORMATO MAIS COMUM PARA V1MODEL
V1Switch(
    P(), // Parser
    ingress(), // Ingress control
    egress(), // Egress control
    D() // Deparser
) main; // O nome 'main' é o nome da sua instância de programa
