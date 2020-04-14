nextflow.preview.dsl=2

process solid {
    // Boilerplate and no way to pass input values in.
    afterScript 'source after.sh solid'

    input:
    val(x)

    output:
    // Needing "optional true" is boilerplate, as is the entire errors channel.
    // We need this even for a process that *should* always succeed, because
    // we need to account for unknown errors.
    path 'solid.txt', emit: values optional true
    path 'error.json',  emit: errors optional true

    script:
    """
    echo ${x} > solid.txt
    """
}

process flaky {
    // Boilerplate and no way to pass input values in.
    afterScript 'source after.sh flaky'

    input:
    path(x)

    output:
    // Needing "optional true" is boilerplate, as is the entire errors channel.
    path "*.txt", emit: data optional true
    path 'error.json', emit: errors optional true

    script:
    """
    N=\$(cat ${x})
    Y=\$(mod3.py \$N)
    echo \$Y > flaky.\$N.txt
    """
}

process gen_report {
    publishDir 'results', mode: "copy", overwite: true

    input:
    val(success)
    val(errors)

    output:
    path 'report.txt'

    script:
    just_success = success.join(" ")
    just_errors = errors.join(" ")
    """
    # Combine successes and failures into
    # a single report so all samples are
    # accounted for!
    for f in ${just_success}; do
        res=\$(cat \$f)
        echo "Success: \$res" >> report.txt
    done
    for f in ${just_errors}; do
        res=\$(cat \$f)
        echo "Failures: \$res" >> report.txt
    done
    """
}

workflow {

    samples = Channel.from(1..10)

    solid(samples)

    flaky(solid.out.values)

    errors = solid.out.errors | mix(flaky.out.errors) | collect

    gen_report(flaky.out.data.collect(), errors)

}
