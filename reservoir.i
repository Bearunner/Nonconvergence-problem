[Mesh]
  [./file]
 type = GeneratedMeshGenerator
 dim = 3
 nx = 120
 ny = 120
 nz = 9
 xmin = -3100
 xmax = -2800
 ymin = -150
 ymax = 150
 zmin = -11.25
 zmax = 11.25
[../]
[]

[GlobalParams]
  PorousFlowDictator = dictator
  multiply_by_density = true
  porepressure = porepressure
  temperature = temperature
  gravity = '-9.81 0 0'
  execute_on = 'initial timestep_begin'
[]

[FluidProperties]
  [water_uo]
    type = SimpleFluidProperties
    bulk_modulus = 2E10
    viscosity = 1.0e-3
    density0 = 1000.0
    thermal_expansion = 0.0
  []
[]

[UserObjects]
  [./dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'porepressure'
    number_fluid_phases = 1
    number_fluid_components = 1
  [../]
  [produced_mass_water]
  type = PorousFlowSumQuantity
  []
  [produced_heat]
   type = PorousFlowSumQuantity
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [ppss]
    type = PorousFlow1PhaseFullySaturated
  []
  [./simple_fluid]
    type = PorousFlowSingleComponentFluid
    fp = water_uo
    phase = 0
  [../]
  [diff_aquifer]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '0'
    tortuosity = 1
  []
  [porosity_aquifer]
    type = PorousFlowPorosityConst
    porosity = 0.1
  []
  [permeability_aquifer]
    type = PorousFlowPermeabilityConst
    permeability = '1e-13 0 0   0 1e-13 0   0 0 1e-13'
  []
  [relp]
    type = PorousFlowRelativePermeabilityConst
    phase = 0
  []
  [rock_heat]
    type = PorousFlowMatrixInternalEnergy
    specific_heat_capacity = 950
    density = 2500
  []
  [thermal_conductivity]
    type = PorousFlowThermalConductivityFromPorosity
    lambda_s = '2 0 0   0 2 0   0 0 2'
    lambda_f = '0.6 0 0   0 0.6 0   0 0 0.6'
  []
  [massfrac]
    type = PorousFlowMassFraction
  []
[]

[BCs]
[]

[ICs]
  [./p_ic]
   type = FunctionIC
   variable = porepressure
   function = hydrostatic
  [../]
  [./T_ic]
    type = FunctionIC
    variable = temperature
    function = thermalgradient
   [../]
[]

[Functions]
  [./hydrostatic]
    type = ParsedFunction
    expression = '1e5-1000*9.81*x'
  [../]
  [./thermalgradient]
    type = ParsedFunction
    expression = '293.15-0.03*x'
  [../]
[]

[Variables]
  [porepressure]
    scaling = 1e-1
  []
  [temperature]
    scaling = 1e-7
  []
[]

[Kernels]
  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = porepressure
  []
  [adv0]
    type = PorousFlowAdvectiveFlux
    fluid_component = 0
    variable = porepressure
  []
  [diff0]
    type = PorousFlowDispersiveFlux
    fluid_component = 0
    variable = porepressure
    disp_trans = 0
    disp_long = 0
  []
  [EnergyTransient]
    type = PorousFlowEnergyTimeDerivative
    variable = temperature
  []
  [EnergyConduciton]
    type = PorousFlowHeatConduction
    variable = temperature
  []
  [EnergyAdvection]
    type = PorousFlowHeatAdvection
    variable = temperature
  []
[]

[DiracKernels]
  [./inj_pp]
    type = PorousFlowPointSourceFromPostprocessor
    point = '-2950 -100 0'
    variable = porepressure
    mass_flux = 10
  [../]
  [inj_h]
   type = PorousFlowPointEnthalpySourceFromPostprocessor
   variable = temperature
   mass_flux = 10
   point = '-2950 -100 0'
   T_in = 293.15
   pressure = porepressure
   fp = water_uo
 []
 [pro_pp]
 type = PorousFlowPolyLineSink
 variable = porepressure
 SumQuantityUO = produced_mass_water
 mass_fraction_component = 0
 point_file = production.bh
 line_length = 1.0
 fluxes = 10
 p_or_t_vals = 0.0
  []
   [pro_T]
   type = PorousFlowPolyLineSink
   variable = temperature
   SumQuantityUO = produced_heat
   point_file = production.bh
   line_length = 1.0
   fluxes = 10
   p_or_t_vals = 0.0
   use_enthalpy = true
  []
[]

[AuxVariables]
  [velocity_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [velocity_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [velocity_z]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [velocity_x]
    type = PorousFlowDarcyVelocityComponent
    variable = velocity_x
    component = x
  []
  [velocity_y]
    type = PorousFlowDarcyVelocityComponent
    variable = velocity_y
    component = y
  []
  [velocity_z]
    type = PorousFlowDarcyVelocityComponent
    variable = velocity_z
    component = z
  []
[]

[Preconditioning]
  active = 'basic'
  [basic]
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
    petsc_options_value = ' asm      lu           NONZERO                   2'
  []
  [preferred_but_might_not_be_installed]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
  [smp]
  type = SMP
  full = true
  petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
  petsc_options_value = 'gmres      asm      lu           NONZERO                   2             '
[]

[]

[Executioner]
  type = Transient
  start_time =  0
  end_time = 1e6
  dtmax = 1e5
  l_tol = 1e-8
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  l_max_its = 50
  nl_max_its = 25
  solve_type = NEWTON
[./TimeStepper]
  type = IterationAdaptiveDT
  dt = 1
  growth_factor = 1.5
[../]
 []

[Outputs]
  print_linear_residuals = true
  [exodus]
   type = Exodus
  []
[]

[Debug]
  show_var_residual_norms = true
[]
 
