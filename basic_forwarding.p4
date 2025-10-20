#include <tna.p4>

header ethernet_t {
    bit<48> dst_addr;
    bit<48> src_addr;
    bit<16> ether_type;
}

header ipv4_t {
    bit<4> version;
    bit<4> ihl;
    bit<8> diffserv;
    bit<16> total_len;
    bit<16> identification;
    bit<3> flags;
    bit<13> frag_offset;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> hdr_checksum;
    bit<32> src_addr;
    bit<32> dst_addr;
}

struct headers {
    ethernet_t ethernet;
    ipv4_t ipv4;
}

struct metadata {
    bit<16> ingress_port;
    bit<16> egress_port;
}

parser parse_packet(
    packet_in packet,
    out headers hdr,
    inout metadata meta,
    inout standard_metadata_t standard_metadata) {
    
    state start {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            0x0800: parse_ipv4;
            default: accept;
        }
    }
    
    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition accept;
    }
}

control ingress(
    inout headers hdr,
    inout metadata meta,
    inout standard_metadata_t standard_metadata) {
    
    action drop() {
        mark_to_drop(standard_metadata);
    }
    
    action set_egress_port(bit<16> port) {
        meta.egress_port = port;
        standard_metadata.egress_spec = port;
    }
    
    table ipv4_lpm {
        key = {
            hdr.ipv4.dst_addr: lpm;
        }
        actions = {
            set_egress_port;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop;
    }
    
    apply {
        if (hdr.ipv4.isValid()) {
            ipv4_lpm.apply();
        } else {
            drop();
        }
    }
}

control egress(
    inout headers hdr,
    inout metadata meta,
    inout standard_metadata_t standard_metadata) {
    
    apply {
        // Decrement TTL para pacotes IPv4
        if (hdr.ipv4.isValid()) {
            hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
        }
    }
}

control deparse_packet(
    packet_out packet,
    in headers hdr) {
    
    apply {
        packet.emit(hdr.ethernet);
        if (hdr.ipv4.isValid()) {
            packet.emit(hdr.ipv4);
        }
    }
}

control verify_checksum(
    inout headers hdr,
    inout metadata meta) {
    
    apply {
        // Verificação de checksum pode ser adicionada aqui se necessário
    }
}

control compute_checksum(
    inout headers hdr,
    inout metadata meta) {
    
    apply {
        // Recalculo de checksum pode ser adicionado aqui se necessário
    }
}

V1Switch(
    parse_packet(),
    verify_checksum(),
    ingress(),
    egress(),
    compute_checksum(),
    deparse_packet()
) main;
