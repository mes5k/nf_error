nextflow.preview.dsl=2

process solid {
    input:
    val(x)

    output:
    // Needing "optional true" is boilerplate, as is the entire errors channel.
    // We need this even for a process that *should* always succeed, because
    // we need to account for unknown errors.
    path 'solid.txt', emit: values optional true
    path 'errors.json',  emit: errors optional true

    script:
    """
    wrap_err input_number ${x} -- echo ${x} > solid.txt
    """
}

process flaky {
    input:
    path(x)

    output:
    // Needing "optional true" is boilerplate, as is the entire errors channel.
    path "*.dat", emit: data optional true
    path 'errors.json', emit: errors optional true

    script:
    """
    wrap_err description_of_input_channel ${x} --  mod3.py ${x}
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

    errors = solid.out.errors | mix(flaky.out.errors) | view | collect

    gen_report(flaky.out.data.view().collect(), errors)

}
